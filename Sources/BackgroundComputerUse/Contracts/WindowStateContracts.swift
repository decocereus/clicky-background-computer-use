import Foundation

enum StatePipelineContractVersion {
    static let current = "state-pipeline.sky-techniques"
}

public struct PointDTO: Codable {
    public let x: Double
    public let y: Double

    init(x: Double, y: Double) {
        self.x = sanitizedJSONDouble(x)
        self.y = sanitizedJSONDouble(y)
    }
}

public struct FrontmostAppObservationDTO: Codable {
    public let bundleID: String?
}

public struct BackgroundSafetyDTO: Codable {
    public let frontmostBefore: FrontmostAppObservationDTO?
    public let frontmostAfter: FrontmostAppObservationDTO?
    public let backgroundSafeReadObserved: Bool?
    public let backgroundSafeObserved: Bool?

    init(
        frontmostBefore: FrontmostAppObservationDTO?,
        frontmostAfter: FrontmostAppObservationDTO?,
        backgroundSafeReadObserved: Bool? = nil,
        backgroundSafeObserved: Bool? = nil
    ) {
        self.frontmostBefore = frontmostBefore
        self.frontmostAfter = frontmostAfter
        self.backgroundSafeReadObserved = backgroundSafeReadObserved
        self.backgroundSafeObserved = backgroundSafeObserved
    }
}

public struct ResolvedWindowDTO: Codable {
    public let windowID: String
    public let title: String
    public let bundleID: String
    public let pid: Int32
    public let launchDate: String?
    public let windowNumber: Int
    public let frameAppKit: RectDTO
    public let resolutionStrategy: String
}

public struct ScreenshotImageDTO: Codable {
    public let imagePath: String?
    public let imageBase64: String?
    public let mimeType: String?
    public let pixelWidth: Int
    public let pixelHeight: Int
    public let coordinateOrigin: CoordinateOrigin
    public let coordinateSpace: CoordinateSpaceName
    public let captureKind: String
}

public struct ScreenshotDTO: Codable {
    public let status: String
    public let image: ScreenshotImageDTO?
    public let rawRetinaCapture: ScreenshotImageDTO?
    public let coordinateContract: ScreenshotCoordinateContract?
    public let captureError: String?
}

public struct ReadPerformanceDTO: Codable {
    public let resolveMs: Double
    public let captureMs: Double
    public let projectionMs: Double
    public let screenshotMs: Double
    public let totalMs: Double

    init(resolveMs: Double, captureMs: Double, projectionMs: Double, screenshotMs: Double, totalMs: Double) {
        self.resolveMs = sanitizedJSONDouble(resolveMs)
        self.captureMs = sanitizedJSONDouble(captureMs)
        self.projectionMs = sanitizedJSONDouble(projectionMs)
        self.screenshotMs = sanitizedJSONDouble(screenshotMs)
        self.totalMs = sanitizedJSONDouble(totalMs)
    }
}

public struct ValueSummaryDTO: Codable {
    public let kind: String?
    public let preview: String?
    public let length: Int?
    public let truncated: Bool
}

public struct FocusedElementDTO: Codable {
    public let index: Int?
    public let displayRole: String?
    public let title: String?
    public let description: String?
    public let secondaryActions: [String]
}

public struct GetWindowStateDebugDTO: Codable {
    public let diagnostics: AXPipelineV2DiagnosticsDTO?
    public let platformProfile: AXPlatformProfileDTO?
    public let rawCapture: AXRawCaptureResult?
    public let semanticTree: AXSemanticTreeDTO?
    public let projectedTree: AXProjectedTreeDTO?
}

public struct GetWindowStateResponse: Codable {
    public let contractVersion: String
    public let stateToken: String
    public let window: ResolvedWindowDTO
    public let screenshot: ScreenshotDTO
    public let tree: AXPipelineV2TreeDTO
    public let menuPresentation: AXMenuPresentationDTO?
    public let focusedElement: FocusedElementDTO
    public let selectionSummary: AXFocusSelectionSnapshotDTO?
    public let backgroundSafety: BackgroundSafetyDTO
    public let performance: ReadPerformanceDTO
    public let debug: GetWindowStateDebugDTO?
    public let notes: [String]
}
