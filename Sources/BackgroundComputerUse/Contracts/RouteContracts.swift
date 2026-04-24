import Foundation

enum RouteExecutionLaneDTO: String, Encodable {
    case sharedRead = "shared_read"
    case windowRead = "window_read"
    case windowWrite = "window_write"
}

enum BackgroundBehaviorDTO: String, Encodable {
    case backgroundRequired = "background_required"
    case backgroundPreferred = "background_preferred"
    case foregroundAllowed = "foreground_allowed"
    case foregroundRequired = "foreground_required"
}

enum FocusStealPolicyDTO: String, Encodable {
    case forbidden
    case discouraged
    case allowed
    case required
}

enum MainThreadBehaviorDTO: String, Encodable {
    case avoid = "avoid_main_thread"
    case allowed = "main_thread_allowed"
    case required = "main_thread_required"
}

enum RouteImplementationStatusDTO: String, Encodable {
    case implemented
    case scaffolded
}

struct RouteExecutionPolicyDTO: Encodable {
    let lane: RouteExecutionLaneDTO
    let backgroundBehavior: BackgroundBehaviorDTO
    let focusStealPolicy: FocusStealPolicyDTO
    let mainThreadBehavior: MainThreadBehaviorDTO
    let readActRead: Bool
    let allowsConcurrentClients: Bool
    let notes: [String]
}

struct RouteDescriptorDTO: Encodable {
    let id: String
    let method: String
    let path: String
    let category: String
    let summary: String
    let execution: RouteExecutionPolicyDTO
    let implementationStatus: RouteImplementationStatusDTO
    let notes: [String]
}

enum RouteTargetKindDTO: String, Encodable {
    case shared
    case appQuery = "app_query"
    case window
}

struct RouteTargetSummaryDTO: Encodable {
    let kind: RouteTargetKindDTO
    let appQuery: String?
    let windowID: String?

    static let shared = RouteTargetSummaryDTO(kind: .shared, appQuery: nil, windowID: nil)
}

struct RouteExecutionReceiptDTO: Encodable {
    let laneKey: String
    let lane: RouteExecutionLaneDTO
    let backgroundBehavior: BackgroundBehaviorDTO
    let focusStealPolicy: FocusStealPolicyDTO
    let mainThreadBehavior: MainThreadBehaviorDTO
    let coordinatedAt: String
    let executedOnMainThread: Bool
    let readActRead: Bool
}

struct RouteSummaryDTO: Encodable {
    let id: String
    let method: String
    let path: String
    let summary: String
}

struct RouteScaffoldResponse: Encodable {
    let contractVersion: String
    let requestID: String
    let status: String
    let route: RouteSummaryDTO
    let target: RouteTargetSummaryDTO
    let notes: [String]
}
