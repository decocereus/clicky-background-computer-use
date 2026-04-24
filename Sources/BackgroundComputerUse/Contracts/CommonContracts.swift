import Foundation

public enum ImageMode: String, Decodable, Encodable, Hashable {
    case path
    case base64
    case omit
}

enum StateDebugModeDTO: String, Decodable, Encodable {
    case none
    case summary
    case full
}

enum MouseButtonDTO: String, Decodable, Encodable {
    case left
    case right
    case middle
}

enum ResizeHandleDTO: String, Decodable, Encodable {
    case left
    case right
    case top
    case bottom
    case topLeft
    case topRight
    case bottomLeft
    case bottomRight
}

enum ScrollDirectionDTO: String, Decodable, Encodable {
    case up
    case down
    case left
    case right
}

enum ActionVerificationModeDTO: String, Decodable, Encodable {
    case strict
    case fast
}

enum CoordinateSpaceDTO: String, Decodable, Encodable {
    case modelFacingScreenshot
    case rawRetinaCapture
    case windowLocalTopLeft
    case windowLocalAppKitBottomLeft
    case globalEventTapTopLeft
    case axGlobalTopLeft
    case appKitGlobal
}

enum MotionPresentationModeDTO: String, Encodable {
    case none
    case drag
    case resize
    case dragThenResize
}

struct CursorRequestDTO: Decodable, Encodable {
    let id: String?
    let name: String?
    let color: String?
}

struct CursorResponseDTO: Encodable {
    let id: String
    let name: String
    let color: String
    let reused: Bool
}

struct ActionErrorDTO: Encodable {
    let code: String
    let message: String
}
