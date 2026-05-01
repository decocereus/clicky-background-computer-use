import Testing
@testable import BackgroundComputerUse

@Suite
struct TypeTextDispatchPolicyTests {
    @Test
    func webTargetsUseKeyboardEventDispatch() {
        let target = makeTarget(rawRole: "AXTextArea", url: "https://x.com/home")

        #expect(TypeTextRouteService.prefersElementValueDispatch(for: target) == false)
    }

    @Test
    func nativeTextTargetsCanUseElementValueDispatch() {
        let target = makeTarget(rawRole: "AXTextField", url: nil)

        #expect(TypeTextRouteService.prefersElementValueDispatch(for: target))
    }

    private func makeTarget(rawRole: String?, url: String?) -> AXActionTargetSnapshot {
        AXActionTargetSnapshot(
            displayIndex: 1,
            projectedIndex: 1,
            primaryCanonicalIndex: 1,
            canonicalIndices: [1],
            displayRole: "text field",
            rawRole: rawRole,
            rawSubrole: nil,
            title: nil,
            description: nil,
            identifier: nil,
            placeholder: "What is happening?",
            url: url,
            nodeID: "node-1",
            refetchFingerprint: "fingerprint-1",
            refetchLocator: nil,
            projectedValueKind: "string",
            projectedValuePreview: "",
            projectedValueLength: 0,
            projectedValueTruncated: false,
            isValueSettable: true,
            supportsValueSet: true,
            isTextEntry: true,
            isFocused: true,
            isSelected: false,
            parameterizedAttributes: [],
            frameAppKit: RectDTO(x: 100, y: 100, width: 300, height: 44),
            activationPointAppKit: nil,
            suggestedInteractionPointAppKit: PointDTO(x: 130, y: 122)
        )
    }
}
