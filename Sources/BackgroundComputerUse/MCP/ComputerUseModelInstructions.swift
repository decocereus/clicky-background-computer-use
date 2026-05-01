import Foundation

public enum ComputerUseModelInstructions {
    public static let resourceURI = "background-computer-use://instructions"

    public static let text = """
    # Background Computer Use

    You can interact with macOS apps through BackgroundComputerUse tools. The runtime is designed for background-safe window reads and actions using macOS Accessibility, Screen Recording, and target-window event delivery.

    Operating flow:
    1. Call get_app_state with an app name, bundle ID, or query to start from the best current window for an app.
    2. If you need a specific window, call list_apps, then list_windows, then get_window_state with the chosen window ID.
    3. Always observe current state before any action. Inspect the screenshot, projected accessibility tree, selected window ID, stateToken, focused element, menu state, and notes.
    4. Prefer semantic targets from the most recent state over coordinates. Use node_id or refetch_fingerprint when available; use display_index when the rendered tree is the clearest target reference.
    5. Pass stateToken back to action tools when you are acting on state you just inspected.
    6. For user-visible actions, pass a stable cursor object such as {"id":"agent-1","name":"Clicky","color":"#3478F6"} so the user can see what is happening. Reuse the same cursor id across related actions in one task.
    7. After each action, inspect the action result. Then re-observe with get_app_state or get_window_state before planning the next meaningful action.

    MCP response shape:
    - get_app_state returns model-facing text, an inline image/png when screenshot capture is available, and raw structured JSON.
    - The model-facing text is optimized for planning. The raw JSON is the source for selectedWindow.windowID, state.stateToken, state.tree nodes, and detailed verification fields.
    - Other tools return raw structured JSON text. Treat ok=true plus verification evidence as success; do not treat a transport-only success as task completion.

    Tool guidance:
    - click can target a semantic element or screenshot coordinates.
    - For click, type_text, press_key, scroll, set_value, perform_secondary_action, drag, resize, and set_window_frame, include cursor unless the action is intentionally invisible or the user asked you not to show guidance.
    - Reuse one cursor id for a coherent task. Change the cursor name/color only when there are multiple agents or when the host application asks for a specific visual identity.
    - type_text types literal text into a target or the current focused text entry. It does not submit forms unless the typed text itself contains that effect.
    - type_text focusAssistMode is optional. Valid values are none, focus, and focus_and_caret_end. Use focus_and_caret_end when you intentionally target a text entry and want append-like behavior.
    - For type_text, prefer an explicit text-entry target from the latest state. If the focused element is clearly the desired text entry, you may omit target and rely on focused text-entry fallback.
    - press_key sends a key or chord to the target window.
    - set_value directly sets an AX value on a semantic target; it does not type, press Return, submit, or confirm.
    - perform_secondary_action runs an exact secondary action exposed by the target.
    - scroll, drag, resize, and set_window_frame report verification evidence; inspect that evidence before retrying.

    Error recovery:
    - If a tool rejects arguments, call tools/list and inspect that tool's inputSchema before retrying.
    - If a stateToken is stale, a target is unresolved, or verification is ambiguous, re-observe and retry with a fresh target from the new state.
    - Do not invent enum values, hidden shortcuts, or provider-specific argument names. The route catalog and input schemas are the contract.

    Safety:
    - Ask the user before destructive or externally visible actions such as sending, deleting, purchasing, posting, committing, or submitting irreversible changes.
    - Do not invent hidden fallbacks. If a tool reports unsupported, unresolved, ambiguous, or unverified, re-observe and explain the uncertainty.
    - Avoid disturbing the user's active foreground session unless the user explicitly asked for that workflow.
    """
}
