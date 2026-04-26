import Foundation

enum ClickTargetKindDTO: String, Encodable {
    case semanticTarget = "semantic_target"
    case coordinate
}

enum ClickFinalRouteDTO: String, Encodable {
    case coordinateXY = "coordinate_xy"
    case semanticAX = "semantic_ax"
    case axElementPointerXY = "ax_element_pointer_xy"
    case semanticAXThenRemainingXY = "semantic_ax_then_remaining_xy"
    case rejected
}

enum ClickFallbackReasonDTO: String, Encodable {
    case none
    case axCoordinateRequired = "ax_coordinate_required"
    case axMultiClickRequiresXY = "ax_multi_click_requires_xy"
    case axFirstClickUnverifiedUsingFullElementPointer = "ax_first_click_unverified_using_full_element_pointer"
    case missingStableAXCoordinate = "missing_stable_ax_coordinate"
    case unsupportedMouseButton = "unsupported_mouse_button"
    case invalidClickCount = "invalid_click_count"
    case invalidTarget = "invalid_target"
    case staleCoordinateGuard = "stale_coordinate_guard"
    case transportFailed = "transport_failed"
}

enum ClickAXAttemptDTO: String, Encodable {
    case exactPrimaryAXAction = "exact_primary_ax_action"
    case setContainerSelectedRows = "set_container_selected_rows"
    case setRowSelectedTrue = "set_row_selected_true"
    case safeUniqueDescendantRetarget = "safe_unique_descendant_retarget"
    case ambiguousDescendantClick = "ambiguous_descendant_click"
    case coordinateRequired = "coordinate_required"
    case unsupportedPrimaryClick = "unsupported_primary_click"
    case none
}

enum ClickTransportRouteDTO: String, Encodable {
    case axPerformAction = "ax_perform_action"
    case axSetSelectedRows = "ax_set_selected_rows"
    case axSetSelected = "ax_set_selected"
    case nativeBackgroundCoordinate = "native_background_coordinate"
}

enum ClickModeDTO: String, Decodable, Encodable {
    case single
    case double
}

struct ClickRequestedTargetDTO: Encodable {
    let kind: ClickTargetKindDTO
    let target: ActionTargetRequestDTO?
    let x: Double?
    let y: Double?
    let coordinateSpace: CoordinateSpaceName?
}

struct ClickCoordinateMappingDTO: Encodable {
    let inputPoint: PointDTO
    let inputCoordinateSpace: CoordinateSpaceName
    let modelPixelSize: PixelSize
    let scaleToWindowLogical: Scale2D
    let targetPointAppKit: PointDTO
    let eventTapPointTopLeft: PointDTO
    let targetPointSource: String
    let warnings: [String]
}

struct ClickTransportAttemptDTO: Encodable {
    let route: ClickTransportRouteDTO
    let axAttempt: ClickAXAttemptDTO?
    let dispatchPrimitive: String
    let rawStatus: String?
    let transportSuccess: Bool
    let didDispatch: Bool
    let clickCount: Int
    let mouseButton: MouseButtonDTO
    let targetPointAppKit: PointDTO?
    let eventTapPointTopLeft: PointDTO?
    let eventsPrepared: Int?
    let targetPID: Int32?
    let targetWindowNumber: Int?
    let liveElementResolution: String?
    let notes: [String]
}

struct ClickRouteStepDTO: Encodable {
    let route: ClickFinalRouteDTO
    let dispatchSuccess: Bool
    let verificationSuccess: Bool
    let intentSuccess: Bool
    let note: String
}

struct ClickVerificationEvidenceDTO: Encodable {
    let preStateToken: String?
    let postStateToken: String?
    let targetRelocated: Bool
    let refreshedTargetMatchStrategy: String?
    let beforeTargetSelected: Bool?
    let afterTargetSelected: Bool?
    let beforeTargetFocused: Bool?
    let afterTargetFocused: Bool?
    let beforeTargetValuePreview: String?
    let afterTargetValuePreview: String?
    let beforeFocusedNodeID: String?
    let afterFocusedNodeID: String?
    let renderedTextChanged: Bool?
    let selectionSummaryChanged: Bool?
    let focusedElementChanged: Bool?
    let windowTitleChanged: Bool?
    let targetStateChanged: Bool?
    let foregroundPreserved: Bool?
    let verificationNotes: [String]
}

struct ClickResponse: Encodable {
    let contractVersion: String
    let ok: Bool
    let classification: ActionClassificationDTO
    let failureDomain: ActionFailureDomainDTO?
    let summary: String
    let window: ResolvedWindowDTO?
    let requestedTarget: ClickRequestedTargetDTO
    let target: AXActionTargetSnapshotDTO?
    let clickCount: Int?
    let mouseButton: MouseButtonDTO?
    let finalRoute: ClickFinalRouteDTO
    let fallbackReason: ClickFallbackReasonDTO
    let axAttempt: ClickAXAttemptDTO?
    let coordinate: ClickCoordinateMappingDTO?
    let transports: [ClickTransportAttemptDTO]
    let routeSteps: [ClickRouteStepDTO]
    let preStateToken: String?
    let postStateToken: String?
    let cursor: ActionCursorTargetResponseDTO
    let frontmostBundleBefore: String?
    let frontmostBundleBeforeDispatch: String?
    let frontmostBundleAfter: String?
    let warnings: [String]
    let notes: [String]
    let verification: ClickVerificationEvidenceDTO?
}
