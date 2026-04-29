import Foundation
import Testing
@testable import BackgroundComputerUse

@Suite
struct MCPServerTests {
    @Test
    func toolsListUsesPackageRouteCatalog() throws {
        let output = CapturingOutputStream()
        let server = BackgroundComputerUseMCPServer(
            input: StaticInputStream(lines: [
                #"{"jsonrpc":"2.0","id":1,"method":"initialize","params":{}}"#,
                #"{"jsonrpc":"2.0","id":2,"method":"tools/list","params":{}}"#
            ]),
            output: output,
            errorOutput: CapturingOutputStream()
        )

        server.run()

        #expect(output.lines.count == 2)

        let toolsResponse = try parseObject(output.lines[1])
        let result = try #require(toolsResponse["result"] as? [String: Any])
        let tools = try #require(result["tools"] as? [[String: Any]])
        let names = tools.compactMap { $0["name"] as? String }

        #expect(names == RouteRegistry.publicRoutes().filter { $0.method == "POST" }.map(\.id))
        #expect(tools.contains { tool in
            guard tool["name"] as? String == RouteID.getWindowState.rawValue,
                  let schema = tool["inputSchema"] as? [String: Any],
                  let required = schema["required"] as? [String] else {
                return false
            }
            return required.contains("window")
        })
    }

    @Test
    func instructionsResourceIsReadable() throws {
        let output = CapturingOutputStream()
        let server = BackgroundComputerUseMCPServer(
            input: StaticInputStream(lines: [
                #"{"jsonrpc":"2.0","id":1,"method":"resources/read","params":{"uri":"background-computer-use://instructions"}}"#
            ]),
            output: output,
            errorOutput: CapturingOutputStream()
        )

        server.run()

        let response = try parseObject(try #require(output.lines.first))
        let result = try #require(response["result"] as? [String: Any])
        let contents = try #require(result["contents"] as? [[String: Any]])
        let first = try #require(contents.first)

        #expect(first["mimeType"] as? String == "text/markdown")
        #expect((first["text"] as? String)?.contains("Always observe current state before any action") == true)
        #expect((first["text"] as? String)?.contains("Valid values are none, focus, and focus_and_caret_end") == true)
        #expect((first["text"] as? String)?.contains("re-observe with get_app_state or get_window_state") == true)
    }

    private func parseObject(_ line: String) throws -> [String: Any] {
        try #require(JSONSerialization.jsonObject(with: Data(line.utf8)) as? [String: Any])
    }
}

private final class StaticInputStream: LineInputStream, @unchecked Sendable {
    private var lines: [String]

    init(lines: [String]) {
        self.lines = lines
    }

    func readLine() -> String? {
        lines.isEmpty ? nil : lines.removeFirst()
    }
}

private final class CapturingOutputStream: LineOutputStream, @unchecked Sendable {
    private(set) var lines: [String] = []

    func writeLine(_ line: String) throws {
        lines.append(line)
    }
}
