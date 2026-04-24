import Foundation

struct RunningAppDTO: Encodable {
    let name: String
    let bundleID: String
    let pid: Int32
    let launchDate: String?
    let activationPolicy: String
    let isActive: Bool
    let isHidden: Bool
    let isFrontmost: Bool
    let onscreenWindowCount: Int
}

struct ListAppsResponse: Encodable {
    let contractVersion: String
    let frontmostApp: RunningAppDTO?
    let runningApps: [RunningAppDTO]
    let notes: [String]
}

public struct RectDTO: Codable {
    public let x: Double
    public let y: Double
    public let width: Double
    public let height: Double

    init(x: Double, y: Double, width: Double, height: Double) {
        self.x = sanitizedJSONDouble(x)
        self.y = sanitizedJSONDouble(y)
        self.width = sanitizedJSONDouble(width)
        self.height = sanitizedJSONDouble(height)
    }
}

struct WindowDTO: Encodable {
    let windowID: String
    let title: String
    let bundleID: String
    let pid: Int32
    let launchDate: String?
    let role: String?
    let subrole: String?
    let windowNumber: Int
    let frameAppKit: RectDTO
    let isFocused: Bool
    let isMain: Bool
    let isMinimized: Bool
    let isOnScreen: Bool
}

struct AppReferenceDTO: Encodable {
    let name: String
    let bundleID: String
    let pid: Int32
    let launchDate: String?
}

struct ListWindowsResponse: Encodable {
    let contractVersion: String
    let app: AppReferenceDTO
    let windows: [WindowDTO]
    let notes: [String]
}
