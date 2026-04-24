import Foundation

enum PressKeyIntentDTO: String, Encodable {
    case openFindOrSearch = "open_find_or_search"
    case selectAll = "select_all"
    case rawKey = "raw_key"
}

enum PressKeyRouteDTO: String, Encodable {
    case semanticFocusExistingSearch = "semantic_focus_existing_search"
    case semanticOpenSearchInWindow = "semantic_open_search_in_window"
    case semanticSelectAllFocusedText = "semantic_select_all_focused_text"
    case nativeKeyDelivery = "native_key_delivery"
    case none
}

struct PressKeyParsedKeyDTO: Encodable {
    let raw: String
    let normalized: String
    let key: String
    let keyCode: Int
    let modifiers: [String]
    let intent: PressKeyIntentDTO
}

struct PressKeyActionDTO: Encodable {
    let route: PressKeyRouteDTO
    let transport: String
    let dispatchPrimitive: String?
    let nativeKeyDelivery: Bool
    let dispatchSucceeded: Bool?
    let rawStatus: String?
    let detail: String
}

struct PressKeySearchVerificationDTO: Encodable {
    let beforeSearchFieldCount: Int
    let afterSearchFieldCount: Int
    let focusedSearchFieldVerified: Bool
    let targetWindowNumberBefore: Int?
    let targetWindowNumberAfter: Int?
    let targetWindowTitleBefore: String?
    let targetWindowTitleAfter: String?
    let frontmostBundleIDBefore: String?
    let frontmostBundleIDAfter: String?
}

struct PressKeySelectionVerificationDTO: Encodable {
    let beforeSelection: TypeTextSelectionRangeDTO?
    let afterSelection: TypeTextSelectionRangeDTO?
    let expectedSelection: TypeTextSelectionRangeDTO?
    let exactSelectionMatch: Bool
}

struct PressKeyVerificationEvidenceDTO: Encodable {
    let preStateToken: String?
    let postStateToken: String?
    let renderedTextChanged: Bool?
    let focusedElementChanged: Bool?
    let textStateChanged: Bool?
    let selectionSummaryChanged: Bool?
    let visualChangeRatio: Double?
    let visualChanged: Bool?
    let search: PressKeySearchVerificationDTO?
    let selection: PressKeySelectionVerificationDTO?
    let verificationNotes: [String]
}

struct PressKeyResponse: Encodable {
    let contractVersion: String
    let ok: Bool
    let classification: ActionClassificationDTO
    let failureDomain: ActionFailureDomainDTO?
    let summary: String
    let window: ResolvedWindowDTO?
    let parsedKey: PressKeyParsedKeyDTO?
    let action: PressKeyActionDTO?
    let preStateToken: String?
    let postStateToken: String?
    let cursor: ActionCursorTargetResponseDTO
    let warnings: [String]
    let notes: [String]
    let verification: PressKeyVerificationEvidenceDTO?
}
