import Foundation

protocol DebugNotesRequest {
    var debug: Bool? { get }
}

enum ActionTargetKindDTO: String, Decodable, Encodable {
    case displayIndex = "display_index"
    case nodeID = "node_id"
    case refetchFingerprint = "refetch_fingerprint"
}

struct ActionTargetRequestDTO: Decodable, Encodable {
    let kind: ActionTargetKindDTO
    let value: String

    var displayIndex: Int? {
        guard kind == .displayIndex else { return nil }
        return Int(value)
    }

    var summary: String {
        switch kind {
        case .displayIndex:
            return "display_index \(value)"
        case .nodeID:
            return "node_id '\(value)'"
        case .refetchFingerprint:
            return "refetch_fingerprint '\(value)'"
        }
    }

    enum CodingKeys: String, CodingKey {
        case kind
        case value
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        kind = try container.decode(ActionTargetKindDTO.self, forKey: .kind)

        switch kind {
        case .displayIndex:
            let index = try container.decode(Int.self, forKey: .value)
            guard index >= 0 else {
                throw DecodingError.dataCorruptedError(
                    forKey: .value,
                    in: container,
                    debugDescription: "display_index targets must use a non-negative integer value."
                )
            }
            value = String(index)

        case .nodeID, .refetchFingerprint:
            let rawValue = try container.decode(String.self, forKey: .value)
                .trimmingCharacters(in: .whitespacesAndNewlines)
            guard rawValue.isEmpty == false else {
                throw DecodingError.dataCorruptedError(
                    forKey: .value,
                    in: container,
                    debugDescription: "\(kind.rawValue) targets must use a non-empty string value."
                )
            }
            value = rawValue
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(kind, forKey: .kind)
        if let displayIndex {
            try container.encode(displayIndex, forKey: .value)
        } else {
            try container.encode(value, forKey: .value)
        }
    }
}

struct ListAppsRequest: Decodable {}

struct ListWindowsRequest: Decodable {
    let app: String
}

struct GetWindowStateRequest: Decodable {
    let window: String
    let includeMenuBar: Bool?
    let menuPath: [String]?
    let webTraversal: AXWebTraversalMode?
    let maxNodes: Int?
    let imageMode: ImageMode?
    let includeRawScreenshot: Bool?
    let debugMode: StateDebugModeDTO?
    let debug: Bool?
    let includeRawCapture: Bool?
    let includeSemanticTree: Bool?
    let includeProjectedTree: Bool?
    let includePlatformProfile: Bool?
    let includeDiagnostics: Bool?
}

struct ClickRequest: Decodable {
    let window: String
    let stateToken: String?
    let target: ActionTargetRequestDTO?
    let x: Double?
    let y: Double?
    let mode: ClickModeDTO?
    let clickCount: Int?
    let mouseButton: MouseButtonDTO?
    let cursor: CursorRequestDTO?
    let includeMenuBar: Bool?
    let maxNodes: Int?
    let imageMode: ImageMode?
    let debug: Bool?

    enum CodingKeys: String, CodingKey {
        case window
        case stateToken
        case target
        case x
        case y
        case mode
        case clickCount
        case mouseButton
        case cursor
        case includeMenuBar
        case maxNodes
        case imageMode
        case debug
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        window = try container.decode(String.self, forKey: .window)
        stateToken = try container.decodeIfPresent(String.self, forKey: .stateToken)
        target = try container.decodeIfPresent(ActionTargetRequestDTO.self, forKey: .target)
        x = try container.decodeIfPresent(Double.self, forKey: .x)
        y = try container.decodeIfPresent(Double.self, forKey: .y)
        mode = try container.decodeIfPresent(ClickModeDTO.self, forKey: .mode)
        clickCount = try container.decodeIfPresent(Int.self, forKey: .clickCount)
        mouseButton = try container.decodeIfPresent(MouseButtonDTO.self, forKey: .mouseButton)
        cursor = try container.decodeIfPresent(CursorRequestDTO.self, forKey: .cursor)
        includeMenuBar = try container.decodeIfPresent(Bool.self, forKey: .includeMenuBar)
        maxNodes = try container.decodeIfPresent(Int.self, forKey: .maxNodes)
        imageMode = try container.decodeIfPresent(ImageMode.self, forKey: .imageMode)
        debug = try container.decodeIfPresent(Bool.self, forKey: .debug)

        let hasTarget = target != nil
        let hasCompleteCoordinate = x != nil && y != nil
        let hasPartialCoordinate = (x != nil) != (y != nil)
        if hasPartialCoordinate {
            throw DecodingError.dataCorruptedError(
                forKey: x == nil ? .x : .y,
                in: container,
                debugDescription: "Click coordinate targets must include both x and y."
            )
        }
        if hasTarget == hasCompleteCoordinate {
            throw DecodingError.dataCorruptedError(
                forKey: .target,
                in: container,
                debugDescription: "Click requests must supply exactly one target form: target or both x and y."
            )
        }
    }
}

struct ScrollRequest: Decodable {
    let window: String
    let stateToken: String?
    let target: ActionTargetRequestDTO
    let direction: ScrollDirectionDTO
    let pages: Int?
    let verificationMode: ActionVerificationModeDTO?
    let cursor: CursorRequestDTO?
    let includeMenuBar: Bool?
    let maxNodes: Int?
    let imageMode: ImageMode?
    let debug: Bool?

    enum CodingKeys: String, CodingKey {
        case window
        case stateToken
        case target
        case direction
        case pages
        case verificationMode
        case cursor
        case includeMenuBar
        case maxNodes
        case imageMode
        case debug
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        window = try container.decode(String.self, forKey: .window)
        stateToken = try container.decodeIfPresent(String.self, forKey: .stateToken)
        target = try container.decode(ActionTargetRequestDTO.self, forKey: .target)
        direction = try container.decode(ScrollDirectionDTO.self, forKey: .direction)
        pages = try container.decodeIfPresent(Int.self, forKey: .pages)
        verificationMode = try container.decodeIfPresent(ActionVerificationModeDTO.self, forKey: .verificationMode)
        cursor = try container.decodeIfPresent(CursorRequestDTO.self, forKey: .cursor)
        includeMenuBar = try container.decodeIfPresent(Bool.self, forKey: .includeMenuBar)
        maxNodes = try container.decodeIfPresent(Int.self, forKey: .maxNodes)
        imageMode = try container.decodeIfPresent(ImageMode.self, forKey: .imageMode)
        debug = try container.decodeIfPresent(Bool.self, forKey: .debug)
    }
}

struct PerformSecondaryActionRequest: Decodable {
    let window: String
    let stateToken: String?
    let target: ActionTargetRequestDTO
    let action: String
    let actionID: String?
    let menuPath: [String]?
    let webTraversal: AXWebTraversalMode?
    let cursor: CursorRequestDTO?
    let includeMenuBar: Bool?
    let maxNodes: Int?
    let imageMode: ImageMode?
    let debug: Bool?

    enum CodingKeys: String, CodingKey {
        case window
        case stateToken
        case target
        case action
        case actionID
        case menuPath
        case webTraversal
        case cursor
        case includeMenuBar
        case maxNodes
        case imageMode
        case debug
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        window = try container.decode(String.self, forKey: .window)
        stateToken = try container.decodeIfPresent(String.self, forKey: .stateToken)
        target = try container.decode(ActionTargetRequestDTO.self, forKey: .target)
        action = try container.decode(String.self, forKey: .action)
        actionID = try container.decodeIfPresent(String.self, forKey: .actionID)
        menuPath = try container.decodeIfPresent([String].self, forKey: .menuPath)
        webTraversal = try container.decodeIfPresent(AXWebTraversalMode.self, forKey: .webTraversal)
        cursor = try container.decodeIfPresent(CursorRequestDTO.self, forKey: .cursor)
        includeMenuBar = try container.decodeIfPresent(Bool.self, forKey: .includeMenuBar)
        maxNodes = try container.decodeIfPresent(Int.self, forKey: .maxNodes)
        imageMode = try container.decodeIfPresent(ImageMode.self, forKey: .imageMode)
        debug = try container.decodeIfPresent(Bool.self, forKey: .debug)
    }
}

struct DragRequest: Decodable {
    let window: String
    let toX: Double
    let toY: Double
    let cursor: CursorRequestDTO?
}

struct ResizeRequest: Decodable {
    let window: String
    let handle: ResizeHandleDTO
    let toX: Double
    let toY: Double
    let cursor: CursorRequestDTO?
}

struct SetWindowFrameRequest: Decodable {
    let window: String
    let x: Double
    let y: Double
    let width: Double
    let height: Double
    let animate: Bool?
    let cursor: CursorRequestDTO?
}

struct TypeTextRequest: Decodable {
    let window: String
    let stateToken: String?
    let target: ActionTargetRequestDTO?
    let text: String
    let focusAssistMode: TypeTextFocusAssistModeDTO?
    let cursor: CursorRequestDTO?
    let includeMenuBar: Bool?
    let maxNodes: Int?
    let imageMode: ImageMode?
    let debug: Bool?

    enum CodingKeys: String, CodingKey {
        case window
        case stateToken
        case target
        case text
        case focusAssistMode
        case cursor
        case includeMenuBar
        case maxNodes
        case imageMode
        case debug
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        window = try container.decode(String.self, forKey: .window)
        stateToken = try container.decodeIfPresent(String.self, forKey: .stateToken)
        target = try container.decodeIfPresent(ActionTargetRequestDTO.self, forKey: .target)
        text = try container.decode(String.self, forKey: .text)
        focusAssistMode = try container.decodeIfPresent(TypeTextFocusAssistModeDTO.self, forKey: .focusAssistMode)
        cursor = try container.decodeIfPresent(CursorRequestDTO.self, forKey: .cursor)
        includeMenuBar = try container.decodeIfPresent(Bool.self, forKey: .includeMenuBar)
        maxNodes = try container.decodeIfPresent(Int.self, forKey: .maxNodes)
        imageMode = try container.decodeIfPresent(ImageMode.self, forKey: .imageMode)
        debug = try container.decodeIfPresent(Bool.self, forKey: .debug)
    }
}

struct PressKeyRequest: Decodable {
    let window: String
    let stateToken: String?
    let key: String
    let cursor: CursorRequestDTO?
    let includeMenuBar: Bool?
    let maxNodes: Int?
    let imageMode: ImageMode?
    let debug: Bool?
}

struct SetValueRequest: Decodable {
    let window: String
    let stateToken: String?
    let target: ActionTargetRequestDTO
    let value: String
    let cursor: CursorRequestDTO?
    let includeMenuBar: Bool?
    let maxNodes: Int?
    let imageMode: ImageMode?
    let debug: Bool?

    enum CodingKeys: String, CodingKey {
        case window
        case stateToken
        case target
        case value
        case cursor
        case includeMenuBar
        case maxNodes
        case imageMode
        case debug
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        window = try container.decode(String.self, forKey: .window)
        stateToken = try container.decodeIfPresent(String.self, forKey: .stateToken)
        target = try container.decode(ActionTargetRequestDTO.self, forKey: .target)
        value = try container.decode(String.self, forKey: .value)
        cursor = try container.decodeIfPresent(CursorRequestDTO.self, forKey: .cursor)
        includeMenuBar = try container.decodeIfPresent(Bool.self, forKey: .includeMenuBar)
        maxNodes = try container.decodeIfPresent(Int.self, forKey: .maxNodes)
        imageMode = try container.decodeIfPresent(ImageMode.self, forKey: .imageMode)
        debug = try container.decodeIfPresent(Bool.self, forKey: .debug)
    }
}

extension ClickRequest: DebugNotesRequest {}
extension ScrollRequest: DebugNotesRequest {}
extension PerformSecondaryActionRequest: DebugNotesRequest {}
extension TypeTextRequest: DebugNotesRequest {}
extension PressKeyRequest: DebugNotesRequest {}
extension SetValueRequest: DebugNotesRequest {}
