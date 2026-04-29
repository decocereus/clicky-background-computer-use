import Foundation

struct RuntimeServices {
    private let coordinator = RuntimeCoordinator()
    private let runningAppService = RunningAppService()
    private let windowListService = WindowListService()
    private let windowStateService: WindowStateService
    private let windowDragRouteService: WindowDragRouteService
    private let windowResizeRouteService: WindowResizeRouteService
    private let setWindowFrameRouteService: SetWindowFrameRouteService
    private let setValueRouteService: SetValueRouteService
    private let typeTextRouteService: TypeTextRouteService
    private let pressKeyRouteService: PressKeyRouteService
    private let scrollRouteService: ScrollRouteService
    private let secondaryActionRouteService: SecondaryActionRouteService
    private let clickRouteService: ClickRouteService

    init(executionOptions: ActionExecutionOptions = .visualCursorEnabled) {
        windowStateService = WindowStateService(executionOptions: executionOptions)
        windowDragRouteService = WindowDragRouteService(executionOptions: executionOptions)
        windowResizeRouteService = WindowResizeRouteService(executionOptions: executionOptions)
        setWindowFrameRouteService = SetWindowFrameRouteService(executionOptions: executionOptions)
        setValueRouteService = SetValueRouteService(executionOptions: executionOptions)
        typeTextRouteService = TypeTextRouteService(executionOptions: executionOptions)
        pressKeyRouteService = PressKeyRouteService(executionOptions: executionOptions)
        scrollRouteService = ScrollRouteService(executionOptions: executionOptions)
        secondaryActionRouteService = SecondaryActionRouteService(executionOptions: executionOptions)
        clickRouteService = ClickRouteService(executionOptions: executionOptions)
    }

    func permissions() -> RuntimePermissionsDTO {
        RuntimePermissionsSnapshot.current().dto
    }

    func listApps() -> ListAppsResponse {
        execute(routeID: .listApps, target: .shared) {
            runningAppService.listApps()
        }
    }

    func listWindows(_ request: ListWindowsRequest) throws -> ListWindowsResponse {
        try execute(
            routeID: .listWindows,
            target: RouteTargetSummaryDTO(kind: .appQuery, appQuery: request.app, windowID: nil)
        ) {
            try windowListService.listWindows(appQuery: request.app)
        }
    }

    func getAppState(_ request: GetAppStateRequest) throws -> GetAppStateResponse {
        try execute(
            routeID: .getAppState,
            target: RouteTargetSummaryDTO(kind: .appQuery, appQuery: request.app, windowID: nil)
        ) {
            let windows = try windowListService.listWindows(appQuery: request.app)
            guard let selectedWindow = Self.selectBestWindow(from: windows.windows) else {
                throw DiscoveryError.windowNotFound(request.app)
            }
            let state = try windowStateService.getWindowState(
                request: GetWindowStateRequest(
                    window: selectedWindow.windowID,
                    includeMenuBar: request.includeMenuBar,
                    menuPath: request.menuPath,
                    webTraversal: request.webTraversal,
                    maxNodes: request.maxNodes,
                    imageMode: request.imageMode,
                    includeRawScreenshot: request.includeRawScreenshot,
                    debugMode: request.debugMode,
                    debug: request.debug,
                    includeRawCapture: request.includeRawCapture,
                    includeSemanticTree: request.includeSemanticTree,
                    includeProjectedTree: request.includeProjectedTree,
                    includePlatformProfile: request.includePlatformProfile,
                    includeDiagnostics: request.includeDiagnostics
                )
            )
            return GetAppStateResponse(
                contractVersion: ContractVersion.current,
                app: windows.app,
                selectedWindow: selectedWindow,
                windows: windows.windows,
                state: state,
                modelContext: Self.makeModelContext(app: windows.app, selectedWindow: selectedWindow, state: state),
                notes: windows.notes + [
                    "Selected window using focused, main, on-screen, then first-window priority."
                ]
            )
        }
    }

    func getWindowState(_ request: GetWindowStateRequest) throws -> GetWindowStateResponse {
        try execute(routeID: .getWindowState, target: windowTarget(request.window)) {
            try windowStateService.getWindowState(request: request)
        }
    }

    func click(_ request: ClickRequest) throws -> ClickResponse {
        try execute(routeID: .click, target: windowTarget(request.window)) {
            try clickRouteService.click(request: request)
        }
    }

    func scroll(_ request: ScrollRequest) throws -> ScrollResponse {
        try execute(routeID: .scroll, target: windowTarget(request.window)) {
            try scrollRouteService.scroll(request: request)
        }
    }

    func performSecondaryAction(_ request: PerformSecondaryActionRequest) throws -> PerformSecondaryActionResponse {
        try execute(routeID: .performSecondaryAction, target: windowTarget(request.window)) {
            try secondaryActionRouteService.performSecondaryAction(request: request)
        }
    }

    func drag(_ request: DragRequest) throws -> DragResponse {
        try execute(routeID: .drag, target: windowTarget(request.window)) {
            try windowDragRouteService.drag(request: request)
        }
    }

    func resize(_ request: ResizeRequest) throws -> ResizeResponse {
        try execute(routeID: .resize, target: windowTarget(request.window)) {
            try windowResizeRouteService.resize(request: request)
        }
    }

    func setWindowFrame(_ request: SetWindowFrameRequest) throws -> SetWindowFrameResponse {
        try execute(routeID: .setWindowFrame, target: windowTarget(request.window)) {
            try setWindowFrameRouteService.setWindowFrame(request: request)
        }
    }

    func typeText(_ request: TypeTextRequest) throws -> TypeTextResponse {
        try execute(routeID: .typeText, target: windowTarget(request.window)) {
            try typeTextRouteService.typeText(request: request)
        }
    }

    func pressKey(_ request: PressKeyRequest) throws -> PressKeyResponse {
        try execute(routeID: .pressKey, target: windowTarget(request.window)) {
            try pressKeyRouteService.pressKey(request: request)
        }
    }

    func setValue(_ request: SetValueRequest) throws -> SetValueResponse {
        try execute(routeID: .setValue, target: windowTarget(request.window)) {
            try setValueRouteService.setValue(request: request)
        }
    }

    private func execute<Response>(
        routeID: RouteID,
        target: RouteTargetSummaryDTO,
        _ work: () throws -> Response
    ) rethrows -> Response {
        let route = RouteRegistry.descriptor(for: routeID)
        return try coordinator.execute(route: route, target: target, work)
    }

    private func windowTarget(_ windowID: String) -> RouteTargetSummaryDTO {
        RouteTargetSummaryDTO(kind: .window, appQuery: nil, windowID: windowID)
    }

    private static func selectBestWindow(from windows: [WindowDTO]) -> WindowDTO? {
        windows.first(where: \.isFocused) ??
            windows.first(where: \.isMain) ??
            windows.first(where: \.isOnScreen) ??
            windows.first
    }

    private static func makeModelContext(
        app: AppReferenceDTO,
        selectedWindow: WindowDTO,
        state: GetWindowStateResponse
    ) -> GetAppStateModelContextDTO {
        let focused = describeFocusedElement(state.focusedElement)
        let screenshotPath = state.screenshot.image?.imagePath
        let summary = "\(app.name) is open to window \"\(selectedWindow.title)\". The current state has \(state.tree.nodeCount) projected accessibility nodes and screenshot status \(state.screenshot.status)."
        var nextActions = [
            "Inspect modelContext.renderedTree and the screenshot before choosing an action.",
            "Use state.stateToken with action tools that act on this observed state.",
            "Prefer node_id or refetch_fingerprint targets from state.tree.nodes when available."
        ]
        if focused == nil {
            nextActions.append("Focused element was not resolved; prefer an explicit semantic target from the tree before typing or pressing keys.")
        }
        return GetAppStateModelContextDTO(
            summary: summary,
            focusedElement: focused,
            screenshotPath: screenshotPath,
            screenshotStatus: state.screenshot.status,
            renderedTree: modelFacingRenderedTree(state.tree.renderedText),
            recommendedNextActions: nextActions
        )
    }

    private static func modelFacingRenderedTree(_ renderedTree: String) -> String {
        renderedTree
            .replacingOccurrences(of: ", web_descendant", with: "")
            .replacingOccurrences(of: "web_descendant, ", with: "")
            .replacingOccurrences(of: " (web_descendant)", with: "")
            .replacingOccurrences(of: "(web_descendant)", with: "")
    }

    private static func describeFocusedElement(_ focused: FocusedElementDTO) -> String? {
        guard focused.index != nil ||
                focused.displayRole != nil ||
                focused.title != nil ||
                focused.description != nil ||
                focused.secondaryActions.isEmpty == false else {
            return nil
        }

        var parts: [String] = []
        if let index = focused.index {
            parts.append("\(index)")
        }
        if let role = focused.displayRole, role.isEmpty == false {
            parts.append(role)
        }
        if let title = focused.title, title.isEmpty == false {
            parts.append("\"\(title)\"")
        }
        if let description = focused.description, description.isEmpty == false {
            parts.append("Description: \(description)")
        }
        if focused.secondaryActions.isEmpty == false {
            parts.append("Secondary Actions: \(focused.secondaryActions.joined(separator: ", "))")
        }
        return parts.joined(separator: " ")
    }
}
