import Foundation

public struct RunningAppDTO: Encodable, Sendable {
    public let name: String
    public let bundleID: String
    public let pid: Int32
    public let launchDate: String?
    public let activationPolicy: String
    public let isActive: Bool
    public let isHidden: Bool
    public let isFrontmost: Bool
    public let onscreenWindowCount: Int
}

public struct ListAppsResponse: Encodable, Sendable {
    public let contractVersion: String
    public let frontmostApp: RunningAppDTO?
    public let runningApps: [RunningAppDTO]
    public let notes: [String]
}

public struct RectDTO: Codable, Sendable {
    public let x: Double
    public let y: Double
    public let width: Double
    public let height: Double

    public init(x: Double, y: Double, width: Double, height: Double) {
        self.x = sanitizedJSONDouble(x)
        self.y = sanitizedJSONDouble(y)
        self.width = sanitizedJSONDouble(width)
        self.height = sanitizedJSONDouble(height)
    }
}

public struct WindowDTO: Encodable, Sendable {
    public let windowID: String
    public let title: String
    public let bundleID: String
    public let pid: Int32
    public let launchDate: String?
    public let role: String?
    public let subrole: String?
    public let windowNumber: Int
    public let frameAppKit: RectDTO
    public let isFocused: Bool
    public let isMain: Bool
    public let isMinimized: Bool
    public let isOnScreen: Bool
}

public struct AppReferenceDTO: Encodable, Sendable {
    public let name: String
    public let bundleID: String
    public let pid: Int32
    public let launchDate: String?
}

public struct ListWindowsResponse: Encodable, Sendable {
    public let contractVersion: String
    public let app: AppReferenceDTO
    public let windows: [WindowDTO]
    public let notes: [String]
}

public struct GetAppStateRequest: Decodable, Sendable {
    public let app: String
    public let includeMenuBar: Bool?
    public let menuPath: [String]?
    public let webTraversal: AXWebTraversalMode?
    public let maxNodes: Int?
    public let imageMode: ImageMode?
    public let includeRawScreenshot: Bool?
    public let debugMode: StateDebugModeDTO?
    public let debug: Bool?
    public let includeRawCapture: Bool?
    public let includeSemanticTree: Bool?
    public let includeProjectedTree: Bool?
    public let includePlatformProfile: Bool?
    public let includeDiagnostics: Bool?

    public init(
        app: String,
        includeMenuBar: Bool? = nil,
        menuPath: [String]? = nil,
        webTraversal: AXWebTraversalMode? = nil,
        maxNodes: Int? = nil,
        imageMode: ImageMode? = nil,
        includeRawScreenshot: Bool? = nil,
        debugMode: StateDebugModeDTO? = nil,
        debug: Bool? = nil,
        includeRawCapture: Bool? = nil,
        includeSemanticTree: Bool? = nil,
        includeProjectedTree: Bool? = nil,
        includePlatformProfile: Bool? = nil,
        includeDiagnostics: Bool? = nil
    ) {
        self.app = app
        self.includeMenuBar = includeMenuBar
        self.menuPath = menuPath
        self.webTraversal = webTraversal
        self.maxNodes = maxNodes
        self.imageMode = imageMode
        self.includeRawScreenshot = includeRawScreenshot
        self.debugMode = debugMode
        self.debug = debug
        self.includeRawCapture = includeRawCapture
        self.includeSemanticTree = includeSemanticTree
        self.includeProjectedTree = includeProjectedTree
        self.includePlatformProfile = includePlatformProfile
        self.includeDiagnostics = includeDiagnostics
    }
}

public struct GetAppStateResponse: Encodable, Sendable {
    public let contractVersion: String
    public let app: AppReferenceDTO
    public let selectedWindow: WindowDTO
    public let windows: [WindowDTO]
    public let state: GetWindowStateResponse
    public let modelContext: GetAppStateModelContextDTO
    public let notes: [String]
}

public struct GetAppStateModelContextDTO: Encodable, Sendable {
    public let summary: String
    public let focusedElement: String?
    public let screenshotPath: String?
    public let screenshotStatus: String
    public let renderedTree: String
    public let recommendedNextActions: [String]
}
