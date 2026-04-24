import Foundation

struct RuntimeCoordinator {
    func execute<T>(
        route: RouteDescriptorDTO,
        target: RouteTargetSummaryDTO,
        _ work: () throws -> T
    ) rethrows -> T {
        let scope = executionScope(for: route.execution.lane, target: target)
        return try RuntimeExecutionQueue.sync(scope: scope, work)
    }

    func scaffold(
        route: RouteDescriptorDTO,
        target: RouteTargetSummaryDTO
    ) -> HTTPResponse {
        let requestID = UUID().uuidString
        let scope = executionScope(for: route.execution.lane, target: target)

        RuntimeExecutionQueue.sync(scope: scope) {
            applyScaffoldDelayIfRequested()
        }

        let response = RouteScaffoldResponse(
            contractVersion: ContractVersion.current,
            requestID: requestID,
            status: "scaffolded_not_implemented",
            route: RouteSummaryDTO(
                id: route.id,
                method: route.method,
                path: route.path,
                summary: route.summary
            ),
            target: target,
            notes: [
                "This route is registered, but its subsystem implementation has not been wired in yet."
            ]
        )

        return .json(
            response,
            statusCode: 501,
            reasonPhrase: "Not Implemented"
        )
    }

    private func executionScope(
        for lane: RouteExecutionLaneDTO,
        target: RouteTargetSummaryDTO
    ) -> RuntimeExecutionScope {
        switch lane {
        case .sharedRead:
            return .sharedRead
        case .windowRead:
            return .windowRead(target.windowID ?? "__missing_window__")
        case .windowWrite:
            return .windowWrite(target.windowID ?? "__missing_window__")
        }
    }

    private func applyScaffoldDelayIfRequested() {
        let environment = ProcessInfo.processInfo.environment
        guard let rawDelay = environment["BACKGROUND_COMPUTER_USE_SCAFFOLD_DELAY_MS"],
              let milliseconds = Int(rawDelay),
              milliseconds > 0 else {
            return
        }

        Thread.sleep(forTimeInterval: Double(milliseconds) / 1_000)
    }
}
