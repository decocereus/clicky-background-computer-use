# BackgroundComputerUse Cleanup And Validation Plan

This plan assumes there are no active external API consumers. We should move the API surface forward wholesale instead of preserving old field names, compatibility aliases, legacy behavior, or bridge shims.

## Guiding Decisions

- Delete obsolete code instead of wrapping it.
- Do not keep deprecated request fields, compatibility response fields, legacy target formats, route aliases, or migration layers.
- Prefer one clean canonical shape per concept.
- Keep the API simple, composable, and self-documenting.
- Let future DOM/webview routes have their own response shapes where that is clearer; do not over-normalize AX and DOM into one forced abstraction.
- Keep debug payloads explicit and opt-in.
- Validate behavior with tests and live smoke checks before merge.
- Treat window titles as mutable UI state, not stable identity.

## 0. Toolchain Baseline

Current local state:

- Apple CLT Swift is now new enough for the package tools version.
- Swiftly Swift 6.3.1 can build the app target.
- `swift build` succeeds with:

  ```bash
  . "$HOME/.swiftly/env.sh" && swift build
  ```

- `swift test` with Swiftly still fails locally because `XCTest` is unavailable without full Xcode.

Preferred path before broad implementation work:

1. Install a full Xcode that includes Swift 6.2 or newer.
2. Select it with `sudo xcode-select -s /Applications/Xcode.app/Contents/Developer`.
3. Run `sudo xcodebuild -runFirstLaunch` if Xcode asks for first-launch setup.
4. Re-check `swift --version`, `xcrun swift --version`, and `xcodebuild -version`.
5. Run `swift test` from the repo root.

## 1. Stable State Tokens

Problem:

- `StateToken.make(windowID:nodeCount:focusedIndex:generatedAt:)` includes the timestamp, so a reread produces a new token even when the UI state is unchanged.
- Stale-token behavior is inconsistent across actions.

Change:

- Replace timestamp-based state tokens with content-derived state signatures.
- Include stable inputs such as window ID, window frame/title, projected tree digest, focused node identity/index, selection digest, and screenshot dimensions when available.
- Keep `stateToken` as the canonical public freshness token.
- Add a shared `StateFreshnessPolicy` used by all stateful mutating routes.
- Remove any older stale-token behavior that conflicts with the new policy.
- A window title change should change state freshness, because actions can legitimately rename windows.

Tests:

- Same fixture/state produces the same token.
- Focus, selection, tree, or window-frame changes produce a different token.
- Window title changes produce a different token without making the window unresolvable.
- Click accepts a token from the immediately preceding matching state read.
- Every mutating route that accepts a state token follows the same policy.

## 2. Canonical Target Addressing

Problem:

- `elementIndex` can resolve as display index, projected index, or array offset.
- This can dispatch to the wrong node when indices collide.
- Keeping both legacy and canonical targeting would make the public surface messier than necessary.

Change:

- Replace `elementIndex` with one canonical typed target object.
- Suggested shape:

  ```json
  { "target": { "kind": "display_index", "value": 12 } }
  ```

- Supported target kinds should be intentionally small:
  - `display_index`
  - `node_id`
  - `refetch_fingerprint` if it proves reliable enough
- Avoid exposing multiple internal index spaces unless there is a real user-facing need.
- Delete legacy `elementIndex` request handling and docs.
- Reject ambiguous, hidden, or non-rendered targets with clear `invalid_request` or `targeting` errors.
- Update `/v1/routes`, examples, README, contracts, and tests to use only the canonical target object.

Tests:

- Display index collision cannot target a hidden/projected-only node accidentally.
- Node ID and refetch fingerprint resolution work across a reread where display indices shift.
- Hidden/unrendered projected nodes cannot be targeted.
- Old `elementIndex` requests are rejected as invalid request, not silently accepted.

## 3. HTTP Parser Hardening

Problem:

- Duplicate headers can trap through `Dictionary(uniqueKeysWithValues:)`.
- Body/header sizes are unbounded.

Change:

- Parse headers into a case-insensitive structure.
- Explicitly handle duplicate singleton headers like `Content-Length`.
- Add maximum header and body sizes.
- Return `400` for malformed requests and `413` for oversized requests.

Tests:

- Duplicate `Content-Length` is rejected.
- Duplicate non-singleton headers are folded or rejected by policy.
- Oversized header/body is rejected without unbounded append.
- Invalid `Content-Length` returns a versioned bad-request response.

## 4. Shared Action Outcome Contract

Problem:

- Click, scroll, text, key, set-value, secondary action, and motion expose different outcome language.
- The docs tell clients to read fields that some routes do not have.
- Error responses should distinguish failed verification from failed dispatch.

Change:

- Introduce one top-level action outcome contract for action routes:
  - `ok`
  - `classification`
  - `failureDomain`
  - `summary`
  - `verificationStatus`
  - `warnings`
  - route-specific `action`
  - route-specific `verification`
  - optional debug-only diagnostics
- Reserve `ok=true` for verified success or explicitly documented no-op success.
- Use `accepted_unverified` or `verifier_ambiguous` for accepted dispatch without proof.
- Make verification-failed errors say clearly that the requested effect may still have happened.
- Delete old route-specific outcome wording once the shared contract lands.

Tests:

- Secondary action accepted without verifier is not reported as verified success.
- Press-key event construction failure is `failureDomain=transport`.
- Scroll boundary cannot override a later dispatch failure.
- Motion routes expose the same top-level outcome fields.
- Verification failure messages are explicit that verification failed, not necessarily the underlying action.

## 5. Validate Before Capture Or Cursor Mutation

Problem:

- Some target-shape errors are discovered after expensive capture.
- Motion routes can resolve/create cursor sessions before validating coordinates and resolving windows.

Change:

- Add preflight request validators for each action route.
- Return `invalid_request` for malformed target shapes before expensive capture.
- Do not create, move, or mutate cursor sessions on validation failure.

Tests:

- Click with no target, partial coordinates, or multiple target forms returns invalid-request semantics.
- Invalid motion coordinates do not create a cursor session.
- Cursor response for rejected action is stable and not misleading.

## 6. Route Registry And API Documentation

Problem:

- Route definitions are spread across `RouteID`, `Router`, `RouteRegistry`, `APIDocumentation`, schemas, examples, and tests.
- `/v1/routes` schemas are stringly typed and cannot express nested objects, enums, nullable fields, or route-specific examples well.
- Public docs contain internal history language like "ports the validated runtime" and stale scaffold notes.

Change:

- Introduce a central `RouteSpec` table, but keep it lean:
  - id
  - family/category
  - method/path
  - request schema
  - response schema
  - handler
  - execution policy
  - usage example
  - errors
- Generate `/v1/routes` from `RouteSpec`.
- Use a small standard schema format that can represent nested objects, arrays, enums, nullability, and one-of target objects.
- Replace implementation-history notes with stable user-facing behavior notes.
- Add route families so future DOM/webview routes can live cleanly beside native AX/window routes.
- Do not add deprecation or compatibility machinery.

Tests:

- Registry and router parity test.
- `/v1/routes` snapshot.
- Every route has family, schema, example, errors, and execution policy.
- No route descriptor references stale scaffold, phase, porting, or internal-history wording.

## 7. Shared Window Matching

Problem:

- Window matching is duplicated in `WindowTargetResolver`, `AXActionTargetResolver`, and `PressKeyRouteService`.
- Cache stores title but does not validate title/frame on hit.

Change:

- Extract `WindowElementMatcher`.
- Return scored candidates and diagnostics.
- Use the matcher in state reads and action live resolution.
- Add cache confidence notes and invalidate low-confidence cache hits.
- Delete duplicated matching paths once the matcher owns the behavior.
- Do not invalidate a cached target solely because the window title changed.
- Use title as diagnostic/tiebreaker state, not primary identity. Primary identity should come from stable app/window facts such as bundle ID, pid, launch date, window number, role, and readable frame.

Tests:

- Exact window number/title/frame match wins.
- Same process/window number with title/frame mismatch is low confidence or invalidated.
- Same process/window number with only title mismatch remains a valid target when role/window number/frame checks pass.
- Press-key and action resolver agree on live window choice.
- Finder duplicate AX records do not cause an `AXScrollArea` to be selected as the motion target.

## 8. Source Boundaries For Future DOM/Webview Work

Problem:

- AX-specific names and assumptions leak through the route-facing state model.
- Future DOM/webview integration will share some concepts but does not need to use identical response shapes.

Change:

- Clean up internal naming so AX-specific details are clearly AX-specific.
- Keep route-facing state fields understandable and source-aware where needed.
- Move raw AX implementation details into debug/source-specific payloads.
- Introduce only the light abstractions that remove current duplication or confusion.
- Do not create a broad compatibility layer or force DOM/webview responses into the current AX response shape.
- Do not implement DOM/webview routes in this cleanup pass.

Tests:

- Existing AX state responses use the new canonical naming and schema.
- Debug AX payload remains available when requested.
- Route docs make clear which fields are source-specific.

## 9. Cursor Architecture

Problem:

- Unknown cursor IDs can silently mutate the default cursor.
- Choreography is hard-coded per action in `CursorCoordinator` and `CursorRuntime`.
- Target projection mixes action coordinates with visual cursor embellishment.
- Public cursor fields expose implementation strings.
- Screenshot compositing can disagree with live overlay culling.

Change:

- Split responsibilities into focused components where it simplifies the current code:
  - `CursorSessionStore`
  - `CursorAnimator`
  - `CursorChoreography`
  - `CursorTargetProjection`
  - `CursorDebugDiagnostics`
- Unknown cursor IDs should either create that requested ID or return explicit not-found, never fall back to `codex`.
- Replace action-specific coordinator methods with choreography descriptors where that reduces duplication.
- Split `actionPoint` from `visualPoint`.
- Make visual offset deterministic by default, with injectable RNG only for optional presentation variance.
- Change public movement/source strings into typed enums or move detailed strings behind debug.
- Update screenshot compositing to consider drawable bounds of glyphs, trails, and effects.

Tests:

- Unknown cursor ID does not mutate default cursor.
- Same action/target produces deterministic visual point in tests.
- Cursor screenshot includes visible trails/effects even when cursor position is just outside bounds.
- Public cursor response fields stay stable and simple.

## 10. Permission And Runtime Hardening

Status:

- Permission presentation was partially cleaned up in `5479ab8`.
- Repeated bootstrap calls now coalesce around one panel, and the panel can be explicitly closed.

Remaining change:

- Add lane-key validation or queue eviction for invalid windows.
- Make execution policy wording match actual main-thread behavior.
- Consider `requestID` propagation into successful route responses for cross-log tracing.
- Add focused tests for the permission-panel behavior already fixed.

Tests:

- Repeated bootstrap calls present at most one panel per missing-permission state.
- Explicitly closing the permission panel suppresses that same missing-permission state.
- Invalid window IDs do not grow queue count unboundedly.
- Route policy snapshot matches known lane/main-thread behavior.

## 11. Public Documentation Cleanup

Change:

- Fix README rough copy.
- Document:
  - install/toolchain requirements
  - permission model
  - state-token semantics
  - target-address semantics
  - action outcome semantics
  - debug behavior
  - verification limitations
- Remove internal implementation-history phrasing from route notes.
- Remove all references to legacy fields or compatibility behavior once the API is moved.

Tests:

- Documentation tests assert every public route has stable user-facing docs.
- Optional lint rejects phrases like "ports", "now live", "scaffolded", and stale phase names in public route notes.

## Deferred Or Removed From This Cleanup Pass

Removed from active plan:

- Public contract guardrail pass that freezes the existing API shape. We are not preserving the current shape.
- Native click symbol-loader refactor. Keep this out of the current cleanup unless it shows up as an actual blocker.
- Full AX element identity interner and broad bounded-search work. This can wait unless we find a concrete bug while cleaning targeting or window matching.

Notes:

- Bounded search is still a reasonable safety improvement eventually, but it is not necessary for the public API cleanup unless live target resolution proves risky during the target-addressing work.
- DOM/webview API design should happen when we build DOM/webview routes, not prematurely in this cleanup.

## Validation Matrix By Change Type

| Change Type | Required Validation |
| --- | --- |
| HTTP/router/parser | Unit tests for parser and router errors; curl smoke for `/health`, `/v1/bootstrap`, `/v1/routes` |
| Public contract/schema | `/v1/routes` snapshot; action response fixture snapshots; README/API docs review |
| State token/target addressing | Fixture tests; mocked action targeting tests; live smoke against one simple app |
| Action response semantics | Unit tests per route classification; representative `ok=false` snapshots |
| Native transports | Live smoke for click/key when permissions are available |
| Cursor changes | Cursor unit tests; compositor pixel tests; live screenshot comparison where possible |
| AX/state pipeline | Fixture replay tests; source-specific debug payload tests |
| Runtime/concurrency | Unit tests where injectable; documented integration smoke for concurrent invalid-window requests |

## Cross-App API Validation

After the cleanup lands and before treating the public API as ready, run an end-to-end validation pass using only the public API surface and `/v1/routes` documentation.

App coverage:

- ChatGPT Atlas
- Zed
- Ghostty
- Messages
- Music
- Notes
- System Settings
- Spotify
- Notion Calendar
- Finder
- TextEdit or another simple native text app

App categories to cover:

- Apple native apps
- Electron or Chromium-based apps
- Swift/AppKit-style native apps
- Terminal-like apps
- Apps with sidebars, lists, editable fields, and menu/secondary actions

Action coverage:

- `list_apps`
- `list_windows`
- `get_window_state`
- `click`
- `scroll`
- `perform_secondary_action`
- `drag`
- `resize`
- `set_window_frame`
- `type_text`
- `press_key`
- `set_value`

Validation rules:

- Use `/v1/bootstrap` and `/v1/routes` as the starting point. Do not rely on private knowledge of request shapes.
- For each app, test only actions that make sense for that app and UI state.
- Record request/response pairs for representative successes and failures.
- Confirm action responses have clean summaries, classifications, failure domains, warnings, and verification status.
- Confirm verification failures clearly say that verification failed and that the underlying action may still have happened when appropriate.
- Confirm screenshots and state reads agree well enough for targeting.
- Confirm title changes after actions do not break follow-up targeting or window resolution.
- Confirm public responses do not expose stale debug notes or internal implementation history.
- Confirm debug-only diagnostics appear only when explicitly requested.
- Run focused motion tests for drag, resize, and set-window-frame on at least Finder, TextEdit, Zed, Ghostty, and one Electron/Chromium app.
- Run focused text/input tests for type, press-key, and set-value on at least Notes, Messages, Ghostty, Zed, and one browser/Electron app.
- Run secondary-action tests anywhere the state surface exposes meaningful secondary actions.

Trajectory review:

- Save or summarize the route sequence used for each app.
- Review failed or inefficient trajectories and decide whether the issue is API design, route docs, state projection, verification, or caller behavior.
- Treat repeated wrong-target attempts as API/documentation bugs unless the route response clearly warned against the target.

Minimal-instructions agent validation:

- After explicit user go-ahead only, run one or more Codex 5.3 Spark subagents with minimal instructions.
- The subagent prompt should provide only the runtime base URL, the instruction to start with `/v1/bootstrap` and `/v1/routes`, and a small user-like task for a target app.
- Do not give the subagent hidden route-shape knowledge or implementation hints.
- Evaluate whether the subagent can operate apps correctly from the self-documenting API alone.
- Review its trajectory for mistaken assumptions, confusing field names, ambiguous targeting, poor error recovery, or overuse of debug fields.
- Use the findings to refine `/v1/routes`, README examples, response summaries, target-address semantics, and error messages.

## Suggested Implementation PR Slices

1. Toolchain/test harness unblock.
2. HTTP parser hardening.
3. Stable state tokens and shared stale-token policy.
4. Canonical target addressing, deleting `elementIndex`.
5. Shared action outcome envelope and route response cleanup.
6. Request preflight before capture/cursor mutation.
7. Lean `RouteSpec` registry and `/v1/routes` schema cleanup.
8. Shared window matching and cache confidence cleanup.
9. Source-boundary cleanup for AX now, without DOM over-normalization.
10. Cursor architecture cleanup.
11. Runtime hardening and route policy wording.
12. README and public route-note polish.
13. Cross-app API validation and trajectory review.

Each slice should land with tests before behavior refactors continue to the next slice.
