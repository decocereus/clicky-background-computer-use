import Foundation

public enum AXMenuMode: String, Codable {
    case none
    case openMenuOnly
    case fullMenuTraversal
}

public enum AXWebTraversalMode: String, Codable {
    case visible
    case full
}

public struct AXMenuPresentationDTO: Codable {
    public let mode: String
    public let source: String
    public let confidence: String
    public let activeTopLevelTitle: String?
    public let activePathTitles: [String]
    public let appPID: Int32
    public let observedAt: String
    public let isOpenMenuLikelyVisible: Bool
    public let warnings: [String]
}

public struct AXNodeIdentitySignatureDTO: Codable {
    public let role: String?
    public let subrole: String?
    public let title: String?
    public let description: String?
    public let valuePreview: String?
    public let identifier: String?
    public let url: String?
}

public struct AXNodeRefetchSignatureDTO: Codable {
    public let role: String?
    public let subrole: String?
    public let roleDescription: String?
    public let title: String?
    public let description: String?
    public let placeholder: String?
    public let help: String?
    public let identifier: String?
    public let urlHost: String?
}

public struct AXNodeRefetchLocatorDTO: Codable {
    public let fingerprint: String
    public let parentFingerprint: String?
    public let ancestorFingerprints: [String]
    public let ordinalWithinParent: Int
    public let rolePath: [String]
    public let signature: AXNodeRefetchSignatureDTO
}

public struct AXNodeIdentityDTO: Codable {
    public let nodeID: String
    public let path: [Int]
    public let pathString: String
    public let signature: AXNodeIdentitySignatureDTO
    public let refetch: AXNodeRefetchLocatorDTO?
}

public struct AXRelationshipSnapshotDTO: Codable {
    public let titleElementIndex: Int?
    public let labelElementIndices: [Int]?
    public let linkedElementIndices: [Int]?
    public let servesAsTitleForIndices: [Int]?
    public let visibleChildIndices: [Int]?
    public let selectedChildIndices: [Int]?
    public let topLevelElementIndex: Int?
    public let disclosedByRowIndex: Int?
}

public struct AXTextExtractionDTO: Codable {
    public let source: String
    public let mode: String
    public let availableModes: [String]
    public let text: String?
    public let attributedText: String?
    public let selectedText: String?
    public let selectedAttributedText: String?
    public let length: Int?
    public let truncated: Bool
    public let supportsTextMarkers: Bool
    public let supportedParameterizedAttributes: [String]

    enum CodingKeys: String, CodingKey {
        case source
        case mode
        case availableModes
        case text
        case attributedText
        case selectedText
        case selectedAttributedText
        case length
        case truncated
        case supportsTextMarkers
        case supportedParameterizedAttributes
    }

    public init(
        source: String,
        mode: String,
        availableModes: [String],
        text: String?,
        attributedText: String?,
        selectedText: String?,
        selectedAttributedText: String?,
        length: Int?,
        truncated: Bool,
        supportsTextMarkers: Bool,
        supportedParameterizedAttributes: [String]
    ) {
        self.source = source
        self.mode = mode
        self.availableModes = availableModes
        self.text = text
        self.attributedText = attributedText
        self.selectedText = selectedText
        self.selectedAttributedText = selectedAttributedText
        self.length = length
        self.truncated = truncated
        self.supportsTextMarkers = supportsTextMarkers
        self.supportedParameterizedAttributes = supportedParameterizedAttributes
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        source = try container.decode(String.self, forKey: .source)
        mode = try container.decode(String.self, forKey: .mode)
        availableModes = try container.decodeIfPresent([String].self, forKey: .availableModes) ?? []
        text = try container.decodeIfPresent(String.self, forKey: .text)
        attributedText = try container.decodeIfPresent(String.self, forKey: .attributedText)
        selectedText = try container.decodeIfPresent(String.self, forKey: .selectedText)
        selectedAttributedText = try container.decodeIfPresent(String.self, forKey: .selectedAttributedText)
        length = try container.decodeIfPresent(Int.self, forKey: .length)
        truncated = try container.decodeIfPresent(Bool.self, forKey: .truncated) ?? false
        supportsTextMarkers = try container.decodeIfPresent(Bool.self, forKey: .supportsTextMarkers) ?? false
        supportedParameterizedAttributes = try container.decodeIfPresent([String].self, forKey: .supportedParameterizedAttributes) ?? []
    }
}

public struct AXActionDescriptorDTO: Codable {
    public let rawName: String
    public let label: String?
    public let description: String?
    public let category: String
    public let hiddenFromSecondaryActions: Bool
}

public struct AXInteractionTraitsDTO: Codable {
    public let supportsPress: Bool
    public let supportsOpen: Bool
    public let supportsPick: Bool
    public let supportsShowMenu: Bool
    public let supportsRaise: Bool
    public let supportsConfirm: Bool
    public let supportsCancel: Bool
    public let supportsIncrement: Bool
    public let supportsDecrement: Bool
    public let supportsScrollToVisible: Bool
    public let supportsScrollToShowDescendant: Bool
    public let supportsValueSet: Bool
    public let isPotentialScrollContainer: Bool
    public let isPotentialScrollBar: Bool
    public let isTextEntry: Bool
}

public struct AXCollectionWindowDTO: Codable {
    public let source: String
    public let totalItems: Int
    public let returnedItems: Int
    public let visibleStartIndex: Int?
    public let visibleEndIndex: Int?
    public let isWindowed: Bool
    public let reason: String
}

public struct AXAffordanceDTO: Codable, Equatable {
    public let kind: String
    public let label: String?
    public let value: String?
    public let sourceCanonicalIndex: Int
    public let sourceNodeID: String?
    public let sourceRole: String?
    public let sourceSubrole: String?
    public let sourceTitle: String?
    public let sourceURL: String?
    public let rawAction: String?
    public let enabled: Bool?
    public let confidence: String
    public let foldedFromHiddenDescendant: Bool
    public let notes: [String]
}

public struct AXSecondaryActionBindingTargetDTO: Codable {
    public let displayIndex: Int?
    public let projectedIndex: Int
    public let primaryCanonicalIndex: Int?
    public let canonicalIndices: [Int]?
    public let nodeID: String?
    public let refetchFingerprint: String?
    public let role: String?
    public let rawRole: String?
    public let rawSubrole: String?
    public let title: String?
    public let frameAppKit: RectDTO?
}

public struct AXSecondaryActionDispatchTargetDTO: Codable {
    public let sourceCanonicalIndex: Int?
    public let sourceNodeID: String?
    public let sourceRole: String?
    public let sourceSubrole: String?
    public let sourceTitle: String?
    public let sourceURL: String?
    public let foldedFromHiddenDescendant: Bool?
}

public struct AXSecondaryActionBindingEvidenceDTO: Codable {
    public let rawActions: [String]
    public let availableActions: [AXActionDescriptorDTO]?
    public let nodeRole: String?
    public let nodeTitle: String?
    public let nodeFlags: [String]
    public let menuPath: [String]?
    public let activeMenuObscured: Bool?
    public let sourceAffordance: AXAffordanceDTO?
    public let notes: [String]
}

public struct AXSecondaryActionBindingDescriptorDTO: Codable {
    public let actionID: String
    public let label: String
    public let source: String
    public let kind: String
    public let dispatchMethod: String
    public let rawName: String?
    public let menuPath: [String]?
    public let target: AXSecondaryActionBindingTargetDTO
    public let dispatchTarget: AXSecondaryActionDispatchTargetDTO?
    public let enabled: Bool
    public let risk: String
    public let exposure: String
    public let visibility: String
    public let modelVisible: Bool
    public let canDispatch: Bool
    public let executionDisposition: String
    public let callabilityReasons: [String]
    public let confidence: String
    public let verificationHint: String
    public let evidence: AXSecondaryActionBindingEvidenceDTO
}

public struct AXFocusSelectionSnapshotDTO: Codable {
    public let focusedCanonicalIndex: Int?
    public let focusedNodeID: String?
    public let selectedCanonicalIndices: [Int]
    public let selectedNodeIDs: [String]
    public let selectedText: String?
    public let selectedTextSource: String?
}

public struct AXEnablementAttemptDTO: Codable {
    public let mode: String
    public let attempted: Bool
    public let before: Bool?
    public let result: String?
    public let after: Bool?
    public let note: String?
}

public struct AXRawNodeDTO: Codable {
    public let index: Int
    public let parentIndex: Int?
    public let depth: Int
    public let childIndices: [Int]
    public let role: String?
    public let subrole: String?
    public let roleDescription: String?
    public let title: String?
    public let placeholder: String?
    public let description: String?
    public let help: String?
    public let identifier: String?
    public let url: String?
    public let valueDescription: String?
    public let valueType: String?
    public let enabled: Bool?
    public let selected: Bool?
    public let expanded: Bool?
    public let isFocused: Bool?
    public let value: ValueSummaryDTO
    public let isValueSettable: Bool?
    public let secondaryActions: [String]
    public let availableActions: [AXActionDescriptorDTO]?
    public let parameterizedAttributes: [String]?
    public let frameAppKit: RectDTO?
    public let activationPointAppKit: PointDTO?
    public let childCount: Int
    public let childSource: String?
    public let collectionInfo: AXCollectionWindowDTO?
    public let identity: AXNodeIdentityDTO?
    public let relationships: AXRelationshipSnapshotDTO?
    public let textExtraction: AXTextExtractionDTO?
    public let interactionTraits: AXInteractionTraitsDTO?
}

public struct AXRawCaptureResult: Codable {
    public let rootIndices: [Int]
    public let nodes: [AXRawNodeDTO]
    public let focusedCanonicalIndex: Int?
    public let focusSelection: AXFocusSelectionSnapshotDTO?
    public let truncated: Bool
}

public struct AXPlatformManualAccessibilityDTO: Codable {
    public let attempted: Bool
    public let before: Bool?
    public let result: String?
    public let after: Bool?
}

public struct AXPlatformProfileDTO: Codable {
    public let bundleID: String?
    public let bundlePath: String?
    public let frameworkHints: [String]
    public let helperAppHints: [String]
    public let isChromiumLike: Bool
    public let isElectronLike: Bool
    public let manualAccessibility: AXPlatformManualAccessibilityDTO?
    public let enablementAttempts: [AXEnablementAttemptDTO]?
    public let notes: [String]
}

public struct AXSemanticNodeDTO: Codable {
    public let index: Int
    public let parentIndex: Int?
    public let depth: Int
    public let rawRole: String?
    public let rawSubrole: String?
    public let displayRole: String
    public let intrinsicLabel: String?
    public let primaryLabelSource: String?
    public let ownerLabel: String?
    public let ownedLabelIndices: [Int]
    public let relationshipOwnerIndex: Int?
    public let description: String?
    public let identifier: String?
    public let url: String?
    public let isInteractive: Bool
    public let isTransparentWrapper: Bool
    public let isMenuChrome: Bool
    public let isWebStructural: Bool
    public let structuralImportance: String
    public let projectionProfileHint: String?
    public let flags: [String]
    public let childIndices: [Int]
    public let frameAppKit: RectDTO?
    public let textExtraction: AXTextExtractionDTO?
}

public struct AXSemanticTreeDTO: Codable {
    public let rootIndices: [Int]
    public let nodes: [AXSemanticNodeDTO]
    public let focusedCanonicalIndex: Int?
    public let focusSelection: AXFocusSelectionSnapshotDTO?
}

public struct AXProjectionPassLogDTO: Codable {
    public let name: String
    public let changedNodeCount: Int
    public let notes: [String]
}

public struct AXClickReadinessMetricsDTO: Codable {
    public let candidateNodeCount: Int
    public let candidateNodesWithGeometry: Int
    public let candidateNodesWithLabel: Int
    public let candidateNodesWithPrimaryAction: Int
    public let wrapperLikeCandidateCount: Int
    public let wrapperLikeCandidatesWithoutLabel: Int
    public let redundantWrapperNodeCount: Int
    public let tinyAnonymousLeafCount: Int
    public let nodesWithActionFiltering: Int
}

public struct AXProjectedNodeDTO: Codable {
    public let projectedIndex: Int
    public let parentProjectedIndex: Int?
    public let depth: Int
    public let primaryCanonicalIndex: Int
    public let canonicalIndices: [Int]
    public let displayRole: String
    public let label: String?
    public let metadata: [String]
    public let flags: [String]
    public let secondaryActions: [String]
    public let secondaryActionBindings: [AXSecondaryActionBindingDescriptorDTO]?
    public let affordances: [AXAffordanceDTO]?
    public let frameAppKit: RectDTO?
    public let childProjectedIndices: [Int]
    public let profileHint: String?
    public let transformNotes: [String]
}

public struct AXV2VisibleLineMappingDTO: Codable {
    public let displayIndex: Int
    public let projectedIndex: Int
    public let primaryCanonicalIndex: Int
    public let canonicalIndices: [Int]
    public let kind: String
}

public struct AXProjectedTreeDTO: Codable {
    public let rootProjectedIndices: [Int]
    public let nodes: [AXProjectedNodeDTO]
    public let lineMappings: [AXV2VisibleLineMappingDTO]
    public let renderedText: String
    public let focusedCanonicalIndex: Int?
    public let focusedProjectedIndex: Int?
    public let focusedDisplayIndex: Int?
    public let profile: String
    public let appliedTransforms: [AXProjectionPassLogDTO]
    public let selectionSummary: AXFocusSelectionSnapshotDTO?
}

public struct AXPipelineV2DiagnosticsDTO: Codable {
    public let rawNodeCount: Int
    public let semanticNodeCount: Int
    public let projectedNodeCount: Int
    public let renderedLineCount: Int
    public let focusedCanonicalIndex: Int?
    public let focusedProjectedIndex: Int?
    public let focusedDisplayIndex: Int?
    public let projectionProfile: String?
    public let appliedTransforms: [String]
    public let selectedTextAvailable: Bool?
    public let clickReadiness: AXClickReadinessMetricsDTO?
    public let notes: [String]
}

public struct AXPipelineV2SurfaceNodeDTO: Codable {
    public let index: Int
    public let displayIndex: Int?
    public let projectedIndex: Int
    public let parentIndex: Int?
    public let depth: Int
    public let primaryCanonicalIndex: Int
    public let canonicalIndices: [Int]
    public let childIndices: [Int]
    public let displayRole: String
    public let rawRole: String?
    public let rawSubrole: String?
    public let title: String?
    public let description: String?
    public let help: String?
    public let identifier: String?
    public let url: String?
    public let nodeID: String?
    public let identity: AXNodeIdentityDTO?
    public let refetch: AXNodeRefetchLocatorDTO?
    public let refetchFingerprint: String?
    public let value: ValueSummaryDTO?
    public let valueKind: String?
    public let isValueSettable: Bool?
    public let flags: [String]
    public let secondaryActions: [String]
    public let secondaryActionBindings: [AXSecondaryActionBindingDescriptorDTO]?
    public let affordances: [AXAffordanceDTO]?
    public let availableActions: [AXActionDescriptorDTO]?
    public let curatedSecondaryActions: [String]?
    public let curatedAvailableActions: [AXActionDescriptorDTO]?
    public let parameterizedAttributes: [String]?
    public let frameAppKit: RectDTO?
    public let activationPointAppKit: PointDTO?
    public let suggestedInteractionPointAppKit: PointDTO?
    public let childCount: Int
    public let collectionInfo: AXCollectionWindowDTO?
    public let interactionTraits: AXInteractionTraitsDTO?
    public let profileHint: String?
    public let transformNotes: [String]
}

public struct AXPipelineV2TreeDTO: Codable {
    public let nodeCount: Int
    public let truncated: Bool
    public let renderedText: String
    public let nodes: [AXPipelineV2SurfaceNodeDTO]
    public let lineMappings: [AXV2VisibleLineMappingDTO]
    public let profile: String?
}

public struct AXPipelineV2Response: Codable {
    public let contractVersion: String
    public let stateToken: String
    public let window: ResolvedWindowDTO
    public let screenshot: ScreenshotDTO
    public let tree: AXPipelineV2TreeDTO
    public let menuPresentation: AXMenuPresentationDTO?
    public let focusedElement: FocusedElementDTO
    public let selectionSummary: AXFocusSelectionSnapshotDTO?
    public let backgroundSafety: BackgroundSafetyDTO
    public let notes: [String]
}

public struct AXPipelineV2Envelope: Codable {
    public let response: AXPipelineV2Response
    public let rawCapture: AXRawCaptureResult
    public let platformProfile: AXPlatformProfileDTO
    public let semanticTree: AXSemanticTreeDTO
    public let projectedTree: AXProjectedTreeDTO
    public let menuPresentation: AXMenuPresentationDTO?
    public let diagnostics: AXPipelineV2DiagnosticsDTO
}

public struct AXPipelineV2Fixture: Codable {
    public let generatedAt: String
    public let scenarioID: String?
    public let appQuery: String?
    public let includeMenuBar: Bool
    public let menuMode: AXMenuMode?
    public let maxNodes: Int
    public let window: ResolvedWindowDTO
    public let rawCapture: AXRawCaptureResult
    public let platformProfile: AXPlatformProfileDTO
    public let menuPresentation: AXMenuPresentationDTO?
    public let notes: [String]
}

public struct AXPipelineV2Scenario: Codable {
    public let id: String
    public let title: String
    public let appQuery: String
    public let bundleID: String
    public let includeMenuBar: Bool
    public let menuMode: AXMenuMode?
    public let maxNodes: Int
    public let windowTitleContains: String?
    public let menuPathComponents: [String]?
    public let keywords: [String]
    public let manualSetupSteps: [String]
    public let notes: [String]
}
