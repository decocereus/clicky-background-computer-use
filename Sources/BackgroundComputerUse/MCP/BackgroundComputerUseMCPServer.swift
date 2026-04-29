import Foundation

public final class BackgroundComputerUseMCPServer {
    private let runtime: BackgroundComputerUseRuntime
    private let input: LineInputStream
    private let output: LineOutputStream
    private let errorOutput: LineOutputStream

    public init(
        runtime: BackgroundComputerUseRuntime = BackgroundComputerUseRuntime(),
        input: LineInputStream = StandardInputStream(),
        output: LineOutputStream = StandardOutputStream(),
        errorOutput: LineOutputStream = StandardErrorStream()
    ) {
        self.runtime = runtime
        self.input = input
        self.output = output
        self.errorOutput = errorOutput
    }

    public func run() {
        while let line = input.readLine() {
            guard line.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
                continue
            }
            handleLine(line)
        }
    }

    private func handleLine(_ line: String) {
        do {
            let message = try JSONSupport.decoder.decode(JSONRPCRequest.self, from: Data(line.utf8))

            guard let id = message.id else {
                handleNotification(message)
                return
            }

            let result = try handleRequest(message)
            send(JSONRPCResponse(id: id, result: result, error: nil))
        } catch let error as MCPError {
            let id = (try? JSONSupport.decoder.decode(JSONRPCRequest.self, from: Data(line.utf8)).id) ?? .null
            send(JSONRPCResponse(id: id, result: nil, error: error.rpcError))
        } catch {
            writeError("Failed to handle MCP message: \(error)")
        }
    }

    private func handleNotification(_ message: JSONRPCRequest) {
        switch message.method {
        case "notifications/initialized", "notifications/cancelled":
            return
        default:
            writeError("Ignoring unsupported MCP notification '\(message.method)'.")
        }
    }

    private func handleRequest(_ request: JSONRPCRequest) throws -> MCPValue {
        switch request.method {
        case "initialize":
            return .object([
                "protocolVersion": .string("2024-11-05"),
                "capabilities": .object([
                    "tools": .object([:]),
                    "resources": .object([:])
                ]),
                "serverInfo": .object([
                    "name": .string("background-computer-use"),
                    "version": .string(ContractVersion.current)
                ])
            ])

        case "ping":
            return .object([:])

        case "tools/list":
            return try encodeValue(MCPToolListResponse(tools: MCPToolCatalog.tools()))

        case "tools/call":
            let params = try request.paramsObject()
            let name = try params.requiredString("name")
            let arguments = params.objectValue("arguments") ?? [:]
            let result = callTool(name: name, arguments: arguments)
            return try encodeValue(result)

        case "resources/list":
            return try encodeValue(
                MCPResourceListResponse(
                    resources: [
                        MCPResource(
                            uri: ComputerUseModelInstructions.resourceURI,
                            name: "Background Computer Use instructions",
                            description: "Model operating instructions for using BackgroundComputerUse tools safely and accurately.",
                            mimeType: "text/markdown"
                        )
                    ]
                )
            )

        case "resources/read":
            let params = try request.paramsObject()
            let uri = try params.requiredString("uri")
            guard uri == ComputerUseModelInstructions.resourceURI else {
                throw MCPError.invalidParams("Unknown resource URI '\(uri)'.")
            }
            return try encodeValue(
                MCPResourceReadResponse(
                    contents: [
                        MCPResourceContent(
                            uri: ComputerUseModelInstructions.resourceURI,
                            mimeType: "text/markdown",
                            text: ComputerUseModelInstructions.text
                        )
                    ]
                )
            )

        default:
            throw MCPError.methodNotFound(request.method)
        }
    }

    private func callTool(name: String, arguments: [String: MCPValue]) -> MCPToolCallResponse {
        do {
            let data = try MCPValue.object(arguments).jsonData()
            let content = try callTool(name: name, body: data)
            return MCPToolCallResponse(
                content: content,
                isError: false
            )
        } catch {
            return MCPToolCallResponse(
                content: [.text(errorPayload(error))],
                isError: true
            )
        }
    }

    private func callTool(name: String, body: Data) throws -> [MCPToolContent] {
        switch name {
        case RouteID.listApps.rawValue:
            _ = try JSONSupport.decoder.decode(ListAppsRequest.self, from: body)
            return try jsonContent(runtime.listApps())
        case RouteID.listWindows.rawValue:
            return try jsonContent(runtime.listWindows(decode(ListWindowsRequest.self, from: body)))
        case RouteID.getAppState.rawValue:
            let response = try runtime.getAppState(decode(GetAppStateRequest.self, from: body))
            return try modelFacingContent(for: response) + [.text(jsonString(response))]
        case RouteID.getWindowState.rawValue:
            return try jsonContent(runtime.getWindowState(decode(GetWindowStateRequest.self, from: body)))
        case RouteID.click.rawValue:
            return try jsonContent(runtime.click(decode(ClickRequest.self, from: body)))
        case RouteID.scroll.rawValue:
            return try jsonContent(runtime.scroll(decode(ScrollRequest.self, from: body)))
        case RouteID.performSecondaryAction.rawValue:
            return try jsonContent(runtime.performSecondaryAction(decode(PerformSecondaryActionRequest.self, from: body)))
        case RouteID.drag.rawValue:
            return try jsonContent(runtime.drag(decode(DragRequest.self, from: body)))
        case RouteID.resize.rawValue:
            return try jsonContent(runtime.resize(decode(ResizeRequest.self, from: body)))
        case RouteID.setWindowFrame.rawValue:
            return try jsonContent(runtime.setWindowFrame(decode(SetWindowFrameRequest.self, from: body)))
        case RouteID.typeText.rawValue:
            return try jsonContent(runtime.typeText(decode(TypeTextRequest.self, from: body)))
        case RouteID.pressKey.rawValue:
            return try jsonContent(runtime.pressKey(decode(PressKeyRequest.self, from: body)))
        case RouteID.setValue.rawValue:
            return try jsonContent(runtime.setValue(decode(SetValueRequest.self, from: body)))
        default:
            throw MCPError.invalidParams("Unknown BackgroundComputerUse tool '\(name)'.")
        }
    }

    private func decode<T: Decodable>(_ type: T.Type, from body: Data) throws -> T {
        try JSONSupport.decoder.decode(type, from: body)
    }

    private func jsonString<T: Encodable>(_ value: T) throws -> String {
        String(decoding: try JSONSupport.encoder.encode(value), as: UTF8.self)
    }

    private func jsonContent<T: Encodable>(_ value: T) throws -> [MCPToolContent] {
        try [.text(jsonString(value))]
    }

    private func modelFacingText(for response: GetAppStateResponse) -> String {
        var lines: [String] = [
            "BackgroundComputerUse app state",
            response.modelContext.summary
        ]
        if let focusedElement = response.modelContext.focusedElement {
            lines.append("Focused element: \(focusedElement)")
        } else {
            lines.append("Focused element: unresolved")
        }
        if let screenshotPath = response.modelContext.screenshotPath {
            lines.append("Screenshot: \(screenshotPath)")
        } else {
            lines.append("Screenshot status: \(response.modelContext.screenshotStatus)")
        }
        lines.append("")
        lines.append("<app_state>")
        lines.append(response.modelContext.renderedTree)
        lines.append("</app_state>")
        lines.append("")
        lines.append("Recommended next actions:")
        lines.append(contentsOf: response.modelContext.recommendedNextActions.map { "- \($0)" })
        return lines.joined(separator: "\n")
    }

    private func modelFacingContent(for response: GetAppStateResponse) throws -> [MCPToolContent] {
        var content: [MCPToolContent] = [.text(modelFacingText(for: response))]
        if let screenshotPath = response.modelContext.screenshotPath,
           let image = try? Data(contentsOf: URL(fileURLWithPath: screenshotPath)) {
            content.append(.image(data: image.base64EncodedString(), mimeType: "image/png"))
        }
        return content
    }

    private func errorPayload(_ error: Error) -> String {
        let response = ErrorResponse(
            error: "tool_call_failed",
            message: String(describing: error),
            requestID: UUID().uuidString,
            recovery: [
                "Call resources/read for \(ComputerUseModelInstructions.resourceURI).",
                "Call tools/list and inspect the input schema for the requested tool.",
                "If acting on a window, call get_window_state again and retry with the latest stateToken and target."
            ]
        )
        return (try? jsonString(response)) ?? #"{"ok":false,"error":"tool_call_failed"}"#
    }

    private func encodeValue<T: Encodable>(_ value: T) throws -> MCPValue {
        try MCPValue.fromJSONData(JSONSupport.encoder.encode(value))
    }

    private func send(_ response: JSONRPCResponse) {
        do {
            try output.writeLine(String(decoding: MCPCodec.encoder.encode(response), as: UTF8.self))
        } catch {
            writeError("Failed to encode MCP response: \(error)")
        }
    }

    private func writeError(_ message: String) {
        try? errorOutput.writeLine("BackgroundComputerUseMCP: \(message)")
    }
}

private enum MCPCodec {
    static let encoder = JSONEncoder()
}

enum MCPToolCatalog {
    static func tools() -> [MCPTool] {
        RouteRegistry.publicRoutes()
            .filter { $0.method == "POST" }
            .map { route in
                MCPTool(
                    name: route.id,
                    description: description(for: route),
                    inputSchema: MCPJSONSchema.fromRouteSchema(route.request)
                )
            }
    }

    private static func description(for route: APIRouteDTO) -> String {
        ([route.summary] + route.notes + route.usage.useAfter + route.usage.successSignals)
            .filter { $0.isEmpty == false }
            .joined(separator: "\n")
    }
}

struct MCPTool: Encodable, Sendable {
    let name: String
    let description: String
    let inputSchema: MCPJSONSchema
}

struct MCPToolListResponse: Encodable, Sendable {
    let tools: [MCPTool]
}

struct MCPToolCallResponse: Encodable, Sendable {
    let content: [MCPToolContent]
    let isError: Bool
}

enum MCPToolContent: Encodable, Sendable {
    case text(String)
    case image(data: String, mimeType: String)

    enum CodingKeys: String, CodingKey {
        case type
        case text
        case data
        case mimeType
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .text(let text):
            try container.encode("text", forKey: .type)
            try container.encode(text, forKey: .text)
        case .image(let data, let mimeType):
            try container.encode("image", forKey: .type)
            try container.encode(data, forKey: .data)
            try container.encode(mimeType, forKey: .mimeType)
        }
    }
}

struct MCPResource: Encodable, Sendable {
    let uri: String
    let name: String
    let description: String
    let mimeType: String
}

struct MCPResourceListResponse: Encodable, Sendable {
    let resources: [MCPResource]
}

struct MCPResourceContent: Encodable, Sendable {
    let uri: String
    let mimeType: String
    let text: String
}

struct MCPResourceReadResponse: Encodable, Sendable {
    let contents: [MCPResourceContent]
}

struct JSONRPCRequest: Decodable {
    let jsonrpc: String?
    let id: MCPRequestID?
    let method: String
    let params: MCPValue?

    func paramsObject() throws -> [String: MCPValue] {
        guard let params else { return [:] }
        guard case .object(let object) = params else {
            throw MCPError.invalidParams("Request params must be an object.")
        }
        return object
    }
}

struct JSONRPCResponse: Encodable {
    let jsonrpc = "2.0"
    let id: MCPRequestID
    let result: MCPValue?
    let error: JSONRPCError?
}

struct JSONRPCError: Encodable, Sendable {
    let code: Int
    let message: String
}

enum MCPError: Error {
    case methodNotFound(String)
    case invalidParams(String)

    var rpcError: JSONRPCError {
        switch self {
        case .methodNotFound(let method):
            JSONRPCError(code: -32601, message: "Method not found: \(method)")
        case .invalidParams(let message):
            JSONRPCError(code: -32602, message: message)
        }
    }
}

enum MCPRequestID: Codable, Sendable {
    case string(String)
    case number(Int)
    case null

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            self = .null
        } else if let int = try? container.decode(Int.self) {
            self = .number(int)
        } else {
            self = .string(try container.decode(String.self))
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let value):
            try container.encode(value)
        case .number(let value):
            try container.encode(value)
        case .null:
            try container.encodeNil()
        }
    }
}

enum MCPValue: Codable, Sendable {
    case object([String: MCPValue])
    case array([MCPValue])
    case string(String)
    case number(Double)
    case bool(Bool)
    case null

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            self = .null
        } else if let object = try? container.decode([String: MCPValue].self) {
            self = .object(object)
        } else if let array = try? container.decode([MCPValue].self) {
            self = .array(array)
        } else if let bool = try? container.decode(Bool.self) {
            self = .bool(bool)
        } else if let int = try? container.decode(Int.self) {
            self = .number(Double(int))
        } else if let number = try? container.decode(Double.self) {
            self = .number(number)
        } else {
            self = .string(try container.decode(String.self))
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .object(let object):
            try container.encode(object)
        case .array(let array):
            try container.encode(array)
        case .string(let string):
            try container.encode(string)
        case .number(let number):
            if number.rounded() == number {
                try container.encode(Int(number))
            } else {
                try container.encode(number)
            }
        case .bool(let bool):
            try container.encode(bool)
        case .null:
            try container.encodeNil()
        }
    }

    static func fromJSONData(_ data: Data) throws -> MCPValue {
        try JSONSupport.decoder.decode(MCPValue.self, from: data)
    }

    func jsonData() throws -> Data {
        try JSONSupport.encoder.encode(self)
    }
}

extension [String: MCPValue] {
    func requiredString(_ key: String) throws -> String {
        guard case .string(let value)? = self[key], value.isEmpty == false else {
            throw MCPError.invalidParams("Missing required string param '\(key)'.")
        }
        return value
    }

    func objectValue(_ key: String) -> [String: MCPValue]? {
        guard case .object(let value)? = self[key] else {
            return nil
        }
        return value
    }
}

public protocol LineInputStream: Sendable {
    func readLine() -> String?
}

public protocol LineOutputStream: Sendable {
    func writeLine(_ line: String) throws
}

public struct StandardInputStream: LineInputStream {
    public init() {}

    public func readLine() -> String? {
        Swift.readLine()
    }
}

public struct StandardOutputStream: LineOutputStream {
    public init() {}

    public func writeLine(_ line: String) throws {
        FileHandle.standardOutput.write(Data((line + "\n").utf8))
    }
}

public struct StandardErrorStream: LineOutputStream {
    public init() {}

    public func writeLine(_ line: String) throws {
        FileHandle.standardError.write(Data((line + "\n").utf8))
    }
}
