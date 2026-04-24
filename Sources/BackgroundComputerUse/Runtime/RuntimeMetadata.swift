enum RuntimeMetadata {
    static let service = "BackgroundComputerUse"
    static let phase = "phase_1_window_motion_live"
    static let bootstrapNotes = [
        "Discovery routes are live, and get_window_state now returns the validated AX state-pipeline V2 tree plus a normalized model-facing screenshot.",
        "Window motion routes now execute through the shared planner/executor/verifier stack with background-safety reporting.",
        "Other mutating action routes remain scaffolded until their subsystem implementations are wired in.",
        "Launch through script/build_and_run.sh to keep bundle identity and TCC grants stable while the API surface is under active development."
    ]
    static let systemRouteNotes = [
        "System routes remain transport-first so clients can discover runtime shape and live route status without touching window lanes."
    ]
}
