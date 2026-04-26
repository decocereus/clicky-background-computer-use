import Foundation

enum SecondaryActionBindingSourceDTO: String, Encodable {
    case directPublicAction = "direct_public_action"
    case foldedAffordance = "folded_affordance"
    case inferredAffordance = "inferred_affordance"
    case stateBinding = "state_binding"
}

enum SecondaryActionDispatchMethodDTO: String, Encodable {
    case axPerformAction = "AXPerformAction"
}

enum SecondaryActionTransportDispositionDTO: String, Encodable {
    case accepted
    case returnedError = "returned_error"
}

enum SecondaryActionSemanticKindDTO: String, Encodable {
    case stateToggle = "state_toggle"
    case cancel
    case close
    case openRepresentedResource = "open_represented_resource"
    case genericAXAction = "generic_ax_action"
}

enum SecondaryActionRouteDTO: String, Encodable {
    case directPublicAction = "direct_public_action"
    case foldedAffordance = "folded_affordance"
    case inferredAffordance = "inferred_affordance"
    case stateBinding = "state_binding"
}

enum SecondaryActionOutcomeStatusDTO: String, Encodable {
    case effectVerified = "effect_verified"
    case acceptedWithoutVerifier = "accepted_without_verifier"
    case noEffectVerified = "no_effect_verified"
    case labelNotExposed = "label_not_exposed"
    case bindingUnavailable = "binding_unavailable"
    case targetUnresolved = "target_unresolved"
    case verifierAmbiguous = "verifier_ambiguous"
}

enum SecondaryActionOutcomeReasonDTO: String, Encodable {
    case expectedEffectObserved = "expected_effect_observed"
    case axAcceptedNoVerifier = "ax_accepted_no_verifier"
    case rawTransportErrorNoEffect = "raw_transport_error_no_effect"
    case transportAcceptedNoEffect = "transport_accepted_no_effect"
    case labelNotExposed = "label_not_exposed"
    case bindingNotFound = "binding_not_found"
    case dispatchTargetNotFound = "dispatch_target_not_found"
    case liveTargetUnresolved = "live_target_unresolved"
    case postStateUnavailable = "post_state_unavailable"
}

struct SecondaryActionRequestedDTO: Encodable {
    let target: ActionTargetRequestDTO
    let label: String
    let actionID: String?
}

struct SecondaryActionBindingDTO: Encodable {
    let actionID: String?
    let label: String
    let source: SecondaryActionBindingSourceDTO
    let dispatchMethod: SecondaryActionDispatchMethodDTO
    let rawName: String
    let dispatchCanonicalIndex: Int
    let dispatchNodeID: String?
    let dispatchRole: String?
    let dispatchSubrole: String?
    let dispatchTitle: String?
    let dispatchURL: String?
    let risk: String?
    let exposure: String?
    let executionDisposition: String?
    let evidence: [String]
}

struct SecondaryActionTransportAttemptDTO: Encodable {
    let dispatchMethod: SecondaryActionDispatchMethodDTO
    let rawName: String
    let rawAXStatus: String
    let transportDisposition: SecondaryActionTransportDispositionDTO
    let transportSuccess: Bool
    let liveElementResolution: String?
    let notes: [String]
}

struct SecondaryActionActionDTO: Encodable {
    let semanticKind: SecondaryActionSemanticKindDTO
    let route: SecondaryActionRouteDTO
    let dispatchPrimitive: String?
    let dispatchSucceeded: Bool?
    let rawAXStatus: String?
    let detail: String
}

struct SecondaryActionOutcomeDTO: Encodable {
    let status: SecondaryActionOutcomeStatusDTO
    let reason: SecondaryActionOutcomeReasonDTO
    let detail: String
    let screenshotRecommended: Bool
}

struct SecondaryActionVerificationDTO: Encodable {
    let beforeTargetSecondaryActions: [String]
    let afterTargetSecondaryActions: [String]?
    let expectedAfterSecondaryAction: String?
    let targetRelocated: Bool
    let refreshedTargetMatchStrategy: String?
    let renderedTextChanged: Bool?
    let menuVisibleBefore: Bool?
    let menuVisibleAfter: Bool?
    let observedEffect: Bool
    let evidence: [String]
}

struct PerformSecondaryActionResponse: Encodable {
    let contractVersion: String
    let ok: Bool
    let classification: ActionClassificationDTO
    let failureDomain: ActionFailureDomainDTO?
    let summary: String
    let window: ResolvedWindowDTO?
    let requestedAction: SecondaryActionRequestedDTO
    let action: SecondaryActionActionDTO?
    let outcome: SecondaryActionOutcomeDTO
    let target: AXActionTargetSnapshotDTO?
    let dispatchTarget: AXActionTargetSnapshotDTO?
    let binding: SecondaryActionBindingDTO?
    let transports: [SecondaryActionTransportAttemptDTO]
    let preStateToken: String?
    let postStateToken: String?
    let postState: AXPipelineV2Response?
    let cursor: ActionCursorTargetResponseDTO
    let warnings: [String]
    let notes: [String]
    let verification: SecondaryActionVerificationDTO?
}
