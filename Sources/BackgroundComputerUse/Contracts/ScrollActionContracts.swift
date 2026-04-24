import Foundation

enum ScrollActionClassificationDTO: String, Encodable {
    case success
    case boundary
    case unsupported
    case unresolved
    case verifierAmbiguous = "verifier_ambiguous"
}

enum ScrollIssueBucketDTO: String, Encodable {
    case none
    case targeting
    case transport
    case verification
    case opacity
}

enum ScrollTransportModeDTO: String, Encodable {
    case backgroundSafeAXLadder = "background_safe_ax_ladder"
    case postToPIDPaging = "post_to_pid_paging"
    case targetedScrollWheelPostToPID = "targeted_scroll_wheel_post_to_pid"
}

enum ScrollStrategyDTO: String, Encodable {
    case axScrollToShowDescendant = "ax_scroll_to_show_descendant"
    case scrollbarValue = "scrollbar_value"
    case axPageAction = "ax_page_action"
    case postToPIDPaging = "post_to_pid_paging"
    case targetedScrollWheelPostToPID = "targeted_scroll_wheel_post_to_pid"
}

struct ScrollCandidateDTO: Encodable {
    let rank: Int
    let score: Int
    let reasons: [String]
    let target: AXActionTargetSnapshotDTO
}

struct ScrollTransportAttemptDTO: Encodable {
    let mode: ScrollTransportModeDTO
    let strategy: ScrollStrategyDTO
    let candidateRank: Int
    let actedOnTarget: AXActionTargetSnapshotDTO
    let liveElementResolution: String?
    let rawStatus: String
    let transportSuccess: Bool
    let didDispatch: Bool
    let boundaryReason: String?
    let notes: [String]
}

struct ScrollVerificationReadDTO: Encodable {
    let readOrdinal: Int
    let delayMilliseconds: Int
    let stateToken: String?
    let observedDirection: String
    let targetedScrollBarDelta: Double?
    let visibleCharacterRangeDelta: Int?
    let visibleTextChanged: Bool
    let visibleLabelSetChanged: Bool
    let sameLabelFrameShift: Double?
    let sameLabelFrameDirectionMatched: Bool
    let targetRegionChangeRatio: Double?
    let fullWindowChangeRatio: Double?
    let directTargetRegionChangeRatio: Double?
    let directFullWindowChangeRatio: Double?
    let wrongPaneMovementLikely: Bool
    let strongEvidence: Bool
    let evidence: [String]
}

struct ScrollVerificationSummaryDTO: Encodable {
    let classification: ScrollActionClassificationDTO
    let issueBucket: ScrollIssueBucketDTO
    let matchedOnReadOrdinal: Int?
    let finalObservedDirection: String
    let evidence: [String]
}

struct ScrollResponse: Encodable {
    let contractVersion: String
    let ok: Bool
    let classification: ScrollActionClassificationDTO
    let failureDomain: ActionFailureDomainDTO?
    let issueBucket: ScrollIssueBucketDTO
    let summary: String
    let window: ResolvedWindowDTO?
    let requestedTarget: AXActionTargetSnapshotDTO?
    let chosenContainer: AXActionTargetSnapshotDTO?
    let direction: ScrollDirectionDTO
    let pages: Int
    let winningMode: ScrollTransportModeDTO?
    let winningStrategy: ScrollStrategyDTO?
    let planCandidates: [ScrollCandidateDTO]
    let transports: [ScrollTransportAttemptDTO]
    let preStateToken: String?
    let postStateToken: String?
    let cursor: ActionCursorTargetResponseDTO
    let frontmostBundleBefore: String?
    let frontmostBundleBeforeDispatch: String?
    let frontmostBundleAfter: String?
    let warnings: [String]
    let notes: [String]
    let verification: ScrollVerificationSummaryDTO?
    let verificationReads: [ScrollVerificationReadDTO]
}
