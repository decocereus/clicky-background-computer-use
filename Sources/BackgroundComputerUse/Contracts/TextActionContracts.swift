import Foundation

enum ActionClassificationDTO: String, Encodable {
    case success
    case unsupported
    case effectNotVerified = "effect_not_verified"
    case verifierAmbiguous = "verifier_ambiguous"
}

enum ActionFailureDomainDTO: String, Encodable {
    case targeting
    case unsupported
    case coercion
    case transport
    case verification
    case appSpecificSemantics = "app_specific_semantics"
}

enum TypeTextFocusAssistModeDTO: String, Decodable, Encodable {
    case none
    case focus
    case focusAndCaretEnd = "focus_and_caret_end"
}

struct AXActionTargetSnapshotDTO: Encodable {
    let elementIndex: Int?
    let displayIndex: Int?
    let projectedIndex: Int
    let primaryCanonicalIndex: Int
    let canonicalIndices: [Int]
    let displayRole: String
    let rawRole: String?
    let rawSubrole: String?
    let title: String?
    let description: String?
    let identifier: String?
    let placeholder: String?
    let url: String?
    let nodeID: String?
    let refetchFingerprint: String?
    let projectedValueKind: String?
    let projectedValuePreview: String?
    let projectedValueLength: Int?
    let projectedValueTruncated: Bool
    let isValueSettable: Bool?
    let supportsValueSet: Bool?
    let isTextEntry: Bool?
    let isFocused: Bool
    let isSelected: Bool
    let parameterizedAttributes: [String]
    let frameAppKit: RectDTO?
    let activationPointAppKit: PointDTO?
    let suggestedInteractionPointAppKit: PointDTO?
}

struct ActionCursorTargetResponseDTO: Encodable {
    let session: CursorResponseDTO
    let targetPointAppKit: PointDTO?
    let targetPointSource: String?
    let moved: Bool
    let moveDurationMs: Double?
    let movement: String
    let warnings: [String]
}

struct SetValueRequestedValueDTO: Encodable {
    let original: String
    let coercedKind: String?
    let coercedPreview: String?
}

struct SetValueObservedValueDTO: Encodable {
    let kind: String?
    let preview: String?
    let stringValue: String?
    let boolValue: Bool?
    let integerValue: Int?
    let doubleValue: Double?
    let truncated: Bool
}

struct SetValueVerificationEvidenceDTO: Encodable {
    let beforeLiveValue: SetValueObservedValueDTO?
    let afterSameElementValue: SetValueObservedValueDTO?
    let afterResolvedLiveValue: SetValueObservedValueDTO?
    let afterProjectedValue: SetValueObservedValueDTO?
    let exactValueMatch: Bool
    let exactValueMatchSource: String?
    let targetRelocated: Bool
    let refreshedTargetMatchStrategy: String?
    let beforeFocusedNodeID: String?
    let afterFocusedNodeID: String?
    let beforeTargetFocused: Bool
    let afterTargetFocused: Bool?
    let beforeTargetSelected: Bool
    let afterTargetSelected: Bool?
    let renderedTextChanged: Bool
    let renderedTextChangedBeyondTargetValue: Bool
    let verificationNotes: [String]
}

struct SetValueResponse: Encodable {
    let contractVersion: String
    let ok: Bool
    let classification: ActionClassificationDTO
    let failureDomain: ActionFailureDomainDTO?
    let summary: String
    let window: ResolvedWindowDTO?
    let target: AXActionTargetSnapshotDTO?
    let requestedValue: SetValueRequestedValueDTO
    let rawAXStatus: String?
    let writePrimitive: String?
    let semanticAppropriate: Bool?
    let semanticReasons: [String]
    let liveElementResolution: String?
    let preStateToken: String?
    let postStateToken: String?
    let cursor: ActionCursorTargetResponseDTO
    let warnings: [String]
    let notes: [String]
    let verification: SetValueVerificationEvidenceDTO?
}

struct TypeTextSelectionRangeDTO: Encodable, Equatable {
    let location: Int
    let length: Int
}

struct TypeTextObservedStateDTO: Encodable {
    let valuePreview: String?
    let valueString: String?
    let length: Int?
    let truncated: Bool
    let selectedTextRange: TypeTextSelectionRangeDTO?
    let isFocused: Bool?
}

struct TypeTextExpectedOutcomeDTO: Encodable {
    let valuePreview: String?
    let valueString: String?
    let selectionRange: TypeTextSelectionRangeDTO?
}

struct TypeTextVerificationEvidenceDTO: Encodable {
    let preparedBeforeLiveState: TypeTextObservedStateDTO?
    let expectedOutcome: TypeTextExpectedOutcomeDTO?
    let afterSameElementState: TypeTextObservedStateDTO?
    let afterResolvedLiveState: TypeTextObservedStateDTO?
    let afterProjectedState: TypeTextObservedStateDTO?
    let exactValueMatch: Bool
    let exactValueMatchSource: String?
    let exactSelectionMatch: Bool?
    let exactSelectionMatchSource: String?
    let targetRelocated: Bool
    let refreshedTargetMatchStrategy: String?
    let beforeFocusedNodeID: String?
    let afterFocusedNodeID: String?
    let beforeTargetFocused: Bool
    let afterTargetFocused: Bool?
    let renderedTextChanged: Bool
    let verificationNotes: [String]
}

struct TypeTextResponse: Encodable {
    let contractVersion: String
    let ok: Bool
    let classification: ActionClassificationDTO
    let failureDomain: ActionFailureDomainDTO?
    let summary: String
    let window: ResolvedWindowDTO?
    let target: AXActionTargetSnapshotDTO?
    let text: String
    let focusAssistMode: TypeTextFocusAssistModeDTO
    let dispatchPrimitive: String?
    let dispatchSucceeded: Bool?
    let semanticAppropriate: Bool?
    let semanticReasons: [String]
    let liveElementResolution: String?
    let preStateToken: String?
    let postStateToken: String?
    let cursor: ActionCursorTargetResponseDTO
    let warnings: [String]
    let notes: [String]
    let verification: TypeTextVerificationEvidenceDTO?
}
