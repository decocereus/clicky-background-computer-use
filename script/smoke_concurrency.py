#!/usr/bin/env python3
import json
import os
import pathlib
import subprocess
import sys
import tempfile
import time
import urllib.request
import urllib.error
from concurrent.futures import ThreadPoolExecutor


ROOT = pathlib.Path(__file__).resolve().parents[1]
MANIFEST_PATH = pathlib.Path(tempfile.gettempdir()) / "background-computer-use" / "runtime-manifest.json"


def wait_for_manifest(deadline: float) -> dict:
    while time.time() < deadline:
        if MANIFEST_PATH.exists():
            try:
                return json.loads(MANIFEST_PATH.read_text())
            except json.JSONDecodeError:
                time.sleep(0.05)
                continue
        time.sleep(0.05)
    raise RuntimeError(f"Timed out waiting for runtime manifest at {MANIFEST_PATH}")


def request_json(method: str, url: str, payload: dict | None = None) -> dict:
    data = None
    headers = {}
    if payload is not None:
        data = json.dumps(payload).encode("utf-8")
        headers["Content-Type"] = "application/json"
    request = urllib.request.Request(url=url, data=data, headers=headers, method=method)
    try:
        with urllib.request.urlopen(request, timeout=10) as response:
            return json.loads(response.read().decode("utf-8"))
    except urllib.error.HTTPError as error:
        return json.loads(error.read().decode("utf-8"))


def timed_burst(label: str, count: int, fn) -> dict:
    started = time.perf_counter()
    with ThreadPoolExecutor(max_workers=count) as executor:
        results = list(executor.map(lambda _: fn(), range(count)))
    elapsed = time.perf_counter() - started
    return {
        "label": label,
        "count": count,
        "elapsedSeconds": round(elapsed, 3),
        "results": results,
        "sample": results[0] if results else None,
    }


def timed_burst_inputs(label: str, inputs: list[dict], fn) -> dict:
    started = time.perf_counter()
    with ThreadPoolExecutor(max_workers=len(inputs)) as executor:
        results = list(executor.map(fn, inputs))
    elapsed = time.perf_counter() - started
    return {
        "label": label,
        "count": len(inputs),
        "elapsedSeconds": round(elapsed, 3),
        "results": results,
        "sample": results[0] if results else None,
    }


def summarize_results(results: list[dict]) -> dict:
    error_count = sum(1 for result in results if "error" in result)
    scaffold_count = sum(1 for result in results if result.get("status") == "scaffolded_not_implemented")
    ok_count = sum(1 for result in results if result.get("ok") is True)
    return {
        "errorCount": error_count,
        "scaffoldCount": scaffold_count,
        "okCount": ok_count,
    }


def choose_window(base_url: str) -> tuple[dict, dict]:
    apps_response = request_json("POST", f"{base_url}/v1/list_apps")
    candidate_app = next(
        (
            app
            for app in apps_response.get("runningApps", [])
            if app.get("onscreenWindowCount", 0) > 0
        ),
        None,
    )
    if candidate_app is None:
        raise RuntimeError("No targetable app with an on-screen window was available for the concurrency smoke.")

    windows_response = request_json(
        "POST",
        f"{base_url}/v1/list_windows",
        {"app": candidate_app["bundleID"]},
    )
    candidate_window = next(
        (
            window
            for window in windows_response.get("windows", [])
            if window.get("isOnScreen") is True
        ),
        None,
    )
    if candidate_window is None:
        raise RuntimeError(
            f"No on-screen window was available for candidate app {candidate_app['bundleID']}."
        )

    return candidate_app, candidate_window


def classify_burst(elapsed: float, delay_seconds: float, count: int, expectation: str) -> dict:
    parallel_upper_bound = delay_seconds * 2.2
    serial_lower_bound = delay_seconds * max(count - 1, 1) * 0.7
    passed = False

    if expectation == "parallel":
        passed = elapsed <= parallel_upper_bound
    elif expectation == "serial":
        passed = elapsed >= serial_lower_bound

    return {
        "expectation": expectation,
        "passed": passed,
        "parallelUpperBoundSeconds": round(parallel_upper_bound, 3),
        "serialLowerBoundSeconds": round(serial_lower_bound, 3),
    }


def classify_parallel_live_reads(results: list[dict], elapsed: float) -> dict:
    total_ms_values = [
        result.get("performance", {}).get("totalMs")
        for result in results
        if isinstance(result.get("performance", {}).get("totalMs"), (int, float))
    ]
    if not total_ms_values:
        return {
            "expectation": "parallel",
            "passed": False,
            "parallelUpperBoundSeconds": None,
            "serialLowerBoundSeconds": None,
        }

    parallel_upper_bound = (max(total_ms_values) / 1_000) * 1.5
    serial_lower_bound = (sum(total_ms_values) / 1_000) * 0.7
    return {
        "expectation": "parallel",
        "passed": elapsed <= parallel_upper_bound,
        "parallelUpperBoundSeconds": round(parallel_upper_bound, 3),
        "serialLowerBoundSeconds": round(serial_lower_bound, 3),
    }


def main() -> int:
    env = os.environ.copy()
    env.setdefault("BACKGROUND_COMPUTER_USE_SCAFFOLD_DELAY_MS", "200")

    if MANIFEST_PATH.exists():
        MANIFEST_PATH.unlink()

    build = subprocess.run(
        ["swift", "build"],
        cwd=ROOT,
        env=env,
        check=True,
        capture_output=True,
        text=True,
    )

    binary = subprocess.run(
        ["swift", "build", "--show-bin-path"],
        cwd=ROOT,
        env=env,
        check=True,
        capture_output=True,
        text=True,
    ).stdout.strip()

    server = subprocess.Popen(
        [str(pathlib.Path(binary) / "BackgroundComputerUse")],
        cwd=ROOT,
        env=env,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )

    try:
        manifest = wait_for_manifest(time.time() + 10)
        base_url = manifest["baseURL"]

        summary = {
            "scaffoldDelayMs": int(env["BACKGROUND_COMPUTER_USE_SCAFFOLD_DELAY_MS"]),
            "buildSummary": build.stdout.splitlines()[-1] if build.stdout else "built",
            "baseURL": base_url,
            "bursts": [],
        }
        delay_seconds = int(env["BACKGROUND_COMPUTER_USE_SCAFFOLD_DELAY_MS"]) / 1_000
        candidate_app, candidate_window = choose_window(base_url)
        candidate_window_id = candidate_window["windowID"]
        summary["candidateWindow"] = {
            "appBundleID": candidate_app["bundleID"],
            "appName": candidate_app["name"],
            "windowID": candidate_window_id,
            "windowTitle": candidate_window.get("title"),
        }

        shared_reads = timed_burst("shared_health_reads", 6, lambda: request_json("GET", f"{base_url}/health"))
        shared_reads["resultSummary"] = summarize_results(shared_reads["results"])
        shared_reads["analysis"] = classify_burst(shared_reads["elapsedSeconds"], delay_seconds, 6, "parallel")
        shared_reads["analysis"]["passed"] = (
            shared_reads["analysis"]["passed"]
            and shared_reads["resultSummary"]["errorCount"] == 0
            and shared_reads["resultSummary"]["okCount"] == shared_reads["count"]
        )
        del shared_reads["results"]
        summary["bursts"].append(shared_reads)

        same_window_reads = timed_burst(
            "same_window_reads_parallel",
            6,
            lambda: request_json(
                "POST",
                f"{base_url}/v1/get_window_state",
                {"window": candidate_window_id},
            ),
        )
        same_window_reads["resultSummary"] = summarize_results(same_window_reads["results"])
        same_window_reads["analysis"] = classify_parallel_live_reads(
            same_window_reads["results"],
            same_window_reads["elapsedSeconds"],
        )
        same_window_reads["analysis"]["passed"] = (
            same_window_reads["analysis"]["passed"]
            and same_window_reads["resultSummary"]["errorCount"] == 0
            and all(result.get("stateToken") for result in same_window_reads["results"])
        )
        del same_window_reads["results"]
        summary["bursts"].append(same_window_reads)

        same_window_clicks = timed_burst(
            "same_window_writes_serial",
            6,
            lambda: request_json(
                "POST",
                f"{base_url}/v1/click",
                {"window": candidate_window_id, "elementIndex": 1},
            ),
        )
        same_window_clicks["resultSummary"] = summarize_results(same_window_clicks["results"])
        same_window_clicks["analysis"] = classify_burst(same_window_clicks["elapsedSeconds"], delay_seconds, 6, "serial")
        same_window_clicks["analysis"]["passed"] = (
            same_window_clicks["analysis"]["passed"]
            and same_window_clicks["resultSummary"]["errorCount"] == 0
            and same_window_clicks["resultSummary"]["scaffoldCount"] == same_window_clicks["count"]
        )
        del same_window_clicks["results"]
        summary["bursts"].append(same_window_clicks)

        same_window_mixed_writes = timed_burst_inputs(
                "same_window_mixed_writes_serial",
            [
                {"route": "click", "body": {"window": candidate_window_id, "elementIndex": 1}},
                {"route": "scroll", "body": {"window": candidate_window_id, "elementIndex": 1, "direction": "down"}},
                {"route": "type_text", "body": {"window": candidate_window_id, "text": "abc"}},
                {"route": "press_key", "body": {"window": candidate_window_id, "key": "enter"}},
            ],
            lambda item: request_json("POST", f"{base_url}/v1/{item['route']}", item["body"]),
        )
        same_window_mixed_writes["resultSummary"] = summarize_results(same_window_mixed_writes["results"])
        same_window_mixed_writes["analysis"] = classify_burst(
            same_window_mixed_writes["elapsedSeconds"],
            delay_seconds,
            same_window_mixed_writes["count"],
            "serial",
        )
        same_window_mixed_writes["analysis"]["passed"] = (
            same_window_mixed_writes["analysis"]["passed"]
            and same_window_mixed_writes["resultSummary"]["errorCount"] == 0
            and same_window_mixed_writes["resultSummary"]["scaffoldCount"] == same_window_mixed_writes["count"]
        )
        del same_window_mixed_writes["results"]
        summary["bursts"].append(same_window_mixed_writes)

        window_ids = [f"window-{index}" for index in range(6)]
        different_window_writes = timed_burst_inputs(
            "different_window_writes_parallel",
            [{"window": window_id, "elementIndex": 1} for window_id in window_ids],
            lambda payload: request_json("POST", f"{base_url}/v1/click", payload),
        )
        different_window_writes["resultSummary"] = summarize_results(different_window_writes["results"])
        different_window_writes["analysis"] = classify_burst(
            different_window_writes["elapsedSeconds"],
            delay_seconds,
            different_window_writes["count"],
            "parallel",
        )
        different_window_writes["analysis"]["passed"] = (
            different_window_writes["analysis"]["passed"]
            and different_window_writes["resultSummary"]["errorCount"] == 0
            and different_window_writes["resultSummary"]["scaffoldCount"] == different_window_writes["count"]
        )
        del different_window_writes["results"]
        summary["bursts"].append(different_window_writes)

        summary["allChecksPassed"] = all(
            burst.get("analysis", {}).get("passed", True)
            for burst in summary["bursts"]
        )

        print(json.dumps(summary, indent=2, sort_keys=True))
        return 0 if summary["allChecksPassed"] else 1
    finally:
        server.terminate()
        try:
            server.wait(timeout=5)
        except subprocess.TimeoutExpired:
            server.kill()
            server.wait(timeout=5)


if __name__ == "__main__":
    raise SystemExit(main())
