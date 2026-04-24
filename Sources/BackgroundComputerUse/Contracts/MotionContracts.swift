import Foundation

struct MotionProjectionDiagnosticsDTO: Encodable {
    let backendID: String
    let targetFrameRate: Double
    let requestedSamples: Int
    let frameWrites: Int
    let skippedSamples: Int
    let projectionElapsedMs: Double
    let effectiveFrameRate: Double
    let lateSamples: Int
    let maxSampleSlipMs: Double
    let writeMs: Double
    let maxWriteMs: Double
    let midProjectionAXReads: Int
    let observedEvents: Int
    let observedFrameChanges: Int
    let observedEffectiveFrameRate: Double
    let observedEchoes: Int
    let divergentObservedEvents: Int
    let invalidObservedEvents: Int
    let maxObservedGapMs: Double
    let firstObservedChangeDelayMs: Double
    let lastObservedChangeDelayMs: Double

    init(
        backendID: String,
        targetFrameRate: Double,
        requestedSamples: Int,
        frameWrites: Int,
        skippedSamples: Int,
        projectionElapsedMs: Double,
        effectiveFrameRate: Double,
        lateSamples: Int,
        maxSampleSlipMs: Double,
        writeMs: Double,
        maxWriteMs: Double,
        midProjectionAXReads: Int,
        observedEvents: Int = 0,
        observedFrameChanges: Int = 0,
        observedEffectiveFrameRate: Double = 0,
        observedEchoes: Int = 0,
        divergentObservedEvents: Int = 0,
        invalidObservedEvents: Int = 0,
        maxObservedGapMs: Double = 0,
        firstObservedChangeDelayMs: Double = 0,
        lastObservedChangeDelayMs: Double = 0
    ) {
        self.backendID = backendID
        self.targetFrameRate = sanitizedJSONDouble(targetFrameRate)
        self.requestedSamples = requestedSamples
        self.frameWrites = frameWrites
        self.skippedSamples = skippedSamples
        self.projectionElapsedMs = sanitizedJSONDouble(projectionElapsedMs)
        self.effectiveFrameRate = sanitizedJSONDouble(effectiveFrameRate)
        self.lateSamples = lateSamples
        self.maxSampleSlipMs = sanitizedJSONDouble(maxSampleSlipMs)
        self.writeMs = sanitizedJSONDouble(writeMs)
        self.maxWriteMs = sanitizedJSONDouble(maxWriteMs)
        self.midProjectionAXReads = midProjectionAXReads
        self.observedEvents = observedEvents
        self.observedFrameChanges = observedFrameChanges
        self.observedEffectiveFrameRate = sanitizedJSONDouble(observedEffectiveFrameRate)
        self.observedEchoes = observedEchoes
        self.divergentObservedEvents = divergentObservedEvents
        self.invalidObservedEvents = invalidObservedEvents
        self.maxObservedGapMs = sanitizedJSONDouble(maxObservedGapMs)
        self.firstObservedChangeDelayMs = sanitizedJSONDouble(firstObservedChangeDelayMs)
        self.lastObservedChangeDelayMs = sanitizedJSONDouble(lastObservedChangeDelayMs)
    }
}

struct MotionPerformanceDTO: Encodable {
    let resolveMs: Double
    let planningMs: Double
    let projectionMs: Double
    let settleMs: Double
    let totalMs: Double
    let projectionDiagnostics: MotionProjectionDiagnosticsDTO?

    init(
        resolveMs: Double,
        planningMs: Double,
        projectionMs: Double,
        settleMs: Double,
        totalMs: Double,
        projectionDiagnostics: MotionProjectionDiagnosticsDTO? = nil
    ) {
        self.resolveMs = sanitizedJSONDouble(resolveMs)
        self.planningMs = sanitizedJSONDouble(planningMs)
        self.projectionMs = sanitizedJSONDouble(projectionMs)
        self.settleMs = sanitizedJSONDouble(settleMs)
        self.totalMs = sanitizedJSONDouble(totalMs)
        self.projectionDiagnostics = projectionDiagnostics
    }
}

struct MotionWindowDTO: Encodable {
    let windowID: String
    let title: String
    let bundleID: String
    let pid: Int32
    let launchDate: String?
    let windowNumber: Int
    let frameBeforeAppKit: RectDTO
    let frameAfterAppKit: RectDTO
}

struct DragRequestedDTO: Encodable {
    let window: String
    let toX: Double
    let toY: Double
    let coordinateSpace: CoordinateSpaceDTO
}

struct DragActionDTO: Encodable {
    let kind: String
    let requested: DragRequestedDTO
    let strategyUsed: String
    let rawStatus: String
    let effectVerified: Bool
    let warnings: [String]
}

struct DragResponse: Encodable {
    let contractVersion: String
    let ok: Bool
    let cursor: CursorResponseDTO
    let action: DragActionDTO
    let window: MotionWindowDTO
    let backgroundSafety: BackgroundSafetyDTO
    let performance: MotionPerformanceDTO
    let error: ActionErrorDTO?
}

struct ResizeRequestedDTO: Encodable {
    let window: String
    let handle: ResizeHandleDTO
    let toX: Double
    let toY: Double
    let coordinateSpace: CoordinateSpaceDTO
}

struct ResizeActionDTO: Encodable {
    let kind: String
    let requested: ResizeRequestedDTO
    let strategyUsed: String
    let rawStatus: String
    let effectVerified: Bool
    let warnings: [String]
}

struct ResizeResponse: Encodable {
    let contractVersion: String
    let ok: Bool
    let cursor: CursorResponseDTO
    let action: ResizeActionDTO
    let window: MotionWindowDTO
    let backgroundSafety: BackgroundSafetyDTO
    let performance: MotionPerformanceDTO
    let error: ActionErrorDTO?
}

struct SetWindowFrameRequestedDTO: Encodable {
    let window: String
    let x: Double
    let y: Double
    let width: Double
    let height: Double
    let animate: Bool
    let coordinateSpace: CoordinateSpaceDTO
}

struct SetWindowFrameActionDTO: Encodable {
    let kind: String
    let requested: SetWindowFrameRequestedDTO
    let strategyUsed: String
    let presentationMode: MotionPresentationModeDTO
    let rawStatus: String
    let effectVerified: Bool
    let warnings: [String]
}

struct SetWindowFrameResponse: Encodable {
    let contractVersion: String
    let ok: Bool
    let cursor: CursorResponseDTO
    let action: SetWindowFrameActionDTO
    let window: MotionWindowDTO
    let backgroundSafety: BackgroundSafetyDTO
    let performance: MotionPerformanceDTO
    let error: ActionErrorDTO?
}
