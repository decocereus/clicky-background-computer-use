import Foundation

struct MCPJSONSchema: Encodable, Sendable {
    var type: String?
    var description: String?
    var properties: [String: MCPJSONSchema]?
    var required: [String]?
    var items: MCPJSONSchemaBox?
    var additionalProperties: Bool?
    var enumValues: [String]?
    var defaultValue: String?

    enum CodingKeys: String, CodingKey {
        case type
        case description
        case properties
        case required
        case items
        case additionalProperties
        case enumValues = "enum"
        case defaultValue = "default"
    }

    init(
        type: String? = nil,
        description: String? = nil,
        properties: [String: MCPJSONSchema]? = nil,
        required: [String]? = nil,
        items: MCPJSONSchema? = nil,
        additionalProperties: Bool? = nil,
        enumValues: [String]? = nil,
        defaultValue: String? = nil
    ) {
        self.type = type
        self.description = description
        self.properties = properties
        self.required = required
        self.items = items.map(MCPJSONSchemaBox.init)
        self.additionalProperties = additionalProperties
        self.enumValues = enumValues
        self.defaultValue = defaultValue
    }

    static func object(
        description: String? = nil,
        properties: [String: MCPJSONSchema] = [:],
        required: [String] = [],
        additionalProperties: Bool = false
    ) -> MCPJSONSchema {
        MCPJSONSchema(
            type: "object",
            description: description,
            properties: properties,
            required: required.isEmpty ? nil : required,
            items: nil,
            additionalProperties: additionalProperties,
            enumValues: nil,
            defaultValue: nil
        )
    }

    static func fromRouteSchema(_ routeSchema: RouteBodySchemaDTO?) -> MCPJSONSchema {
        guard let routeSchema else {
            return .object()
        }

        var properties: [String: MCPJSONSchema] = [:]
        var required: [String] = []

        for field in routeSchema.fields {
            properties[field.name] = schema(for: field)
            if field.required {
                required.append(field.name)
            }
        }

        return .object(properties: properties, required: required)
    }

    private static func schema(for field: RouteFieldDTO) -> MCPJSONSchema {
        var schema = schema(forType: field.type)
        schema.description = field.description
        schema.defaultValue = field.defaultValue
        return schema
    }

    private static func schema(forType type: String) -> MCPJSONSchema {
        let trimmed = type.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmed.hasSuffix("[]") {
            let itemType = String(trimmed.dropLast(2))
            return MCPJSONSchema(type: "array", items: schema(forType: itemType))
        }

        let enumParts = trimmed
            .split(separator: "|")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.isEmpty == false && $0 != "null" }
        if enumParts.count > 1, enumParts.allSatisfy(isLikelyEnumCase) {
            return MCPJSONSchema(type: "string", enumValues: enumParts)
        }

        switch trimmed {
        case "string":
            return MCPJSONSchema(type: "string")
        case "integer":
            return MCPJSONSchema(type: "integer")
        case "number":
            return MCPJSONSchema(type: "number")
        case "boolean":
            return MCPJSONSchema(type: "boolean")
        case "ActionTargetRequest":
            return actionTargetSchema()
        case "CursorRequest":
            return cursorSchema()
        default:
            return MCPJSONSchema(
                type: "object",
                description: "Object shaped as \(trimmed).",
                additionalProperties: true
            )
        }
    }

    private static func actionTargetSchema() -> MCPJSONSchema {
        .object(
            description: "Semantic action target from get_window_state.",
            properties: [
                "kind": MCPJSONSchema(
                    type: "string",
                    description: "Target reference kind.",
                    enumValues: ["display_index", "node_id", "refetch_fingerprint"]
                ),
                "value": MCPJSONSchema(
                    description: "Integer for display_index; string for node_id or refetch_fingerprint."
                )
            ],
            required: ["kind", "value"]
        )
    }

    private static func cursorSchema() -> MCPJSONSchema {
        .object(
            description: "Optional visible cursor request.",
            properties: [
                "id": MCPJSONSchema(type: "string"),
                "name": MCPJSONSchema(type: "string"),
                "color": MCPJSONSchema(type: "string"),
                "visible": MCPJSONSchema(type: "boolean")
            ]
        )
    }

    private static func isLikelyEnumCase(_ value: String) -> Bool {
        value.range(of: #"^[A-Za-z0-9_\-]+$"#, options: .regularExpression) != nil
    }
}

final class MCPJSONSchemaBox: Encodable, @unchecked Sendable {
    let schema: MCPJSONSchema

    init(_ schema: MCPJSONSchema) {
        self.schema = schema
    }

    func encode(to encoder: Encoder) throws {
        try schema.encode(to: encoder)
    }
}
