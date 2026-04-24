import CryptoKit
import Foundation

enum StateToken {
    private static let alphabet = Array("0123456789ABCDEFGHJKMNPQRSTVWXYZ")

    static func make(
        windowID: String,
        title: String,
        frame: CGRect,
        pixelWidth: Int?,
        pixelHeight: Int?
    ) -> String {
        let frameMinX = String(describing: frame.minX)
        let frameMinY = String(describing: frame.minY)
        let frameWidth = String(describing: frame.width)
        let frameHeight = String(describing: frame.height)
        let pixelWidthComponent = pixelWidth.map(String.init) ?? "nil"
        let pixelHeightComponent = pixelHeight.map(String.init) ?? "nil"
        let payload = [
            windowID,
            title,
            frameMinX,
            frameMinY,
            frameWidth,
            frameHeight,
            pixelWidthComponent,
            pixelHeightComponent
        ].joined(separator: "|")
        let digest = SHA256.hash(data: Data(payload.utf8))

        var value: UInt64 = 0
        for byte in digest.prefix(8) {
            value = (value << 8) | UInt64(byte)
        }

        var characters = Array(repeating: Character("0"), count: 13)
        for index in stride(from: 12, through: 0, by: -1) {
            characters[index] = alphabet[Int(value & 31)]
            value >>= 5
        }

        return "st_\(String(characters))"
    }

    static func make(windowID: String, nodeCount: Int, focusedIndex: Int?, generatedAt: Date) -> String {
        let focusedComponent = focusedIndex.map(String.init) ?? "nil"
        let payload = "\(windowID)|\(nodeCount)|\(focusedComponent)|\(Time.iso8601String(from: generatedAt))"
        let digest = SHA256.hash(data: Data(payload.utf8))

        var value: UInt64 = 0
        for byte in digest.prefix(8) {
            value = (value << 8) | UInt64(byte)
        }

        var characters = Array(repeating: Character("0"), count: 13)
        for index in stride(from: 12, through: 0, by: -1) {
            characters[index] = alphabet[Int(value & 31)]
            value >>= 5
        }

        return "st_\(String(characters))"
    }
}
