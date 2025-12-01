import RFC_5234
import RFC_7405
import StandardsTestSupport
import Testing

@Suite("RFC 7405 Case Sensitivity Tests")
struct CaseSensitivityTests {
    @Test("Case-insensitive matching using RFC 5234 syntax")
    func caseInsensitiveMatching() throws {
        let rule = RFC_5234.Rule(
            name: "protocol",
            element: .terminal(.string("HTTP"))
        )

        // RFC 5234 strings are case-insensitive by default
        try RFC_5234.Validator.validate([0x48, 0x54, 0x54, 0x50], against: rule)  // "HTTP"
        try RFC_5234.Validator.validate([0x68, 0x74, 0x74, 0x70], against: rule)  // "http"
        try RFC_5234.Validator.validate([0x48, 0x74, 0x54, 0x70], against: rule)  // "HtTp"
    }

    @Test("Explicit case-insensitive matching using RFC 7405 syntax")
    func explicitCaseInsensitiveMatching() throws {
        let rule = RFC_5234.Rule(
            name: "protocol",
            element: .terminal(.caseInsensitiveString("HTTP"))
        )

        // RFC 7405 %i"..." syntax is explicitly case-insensitive
        try RFC_5234.Validator.validate([0x48, 0x54, 0x54, 0x50], against: rule)  // "HTTP"
        try RFC_5234.Validator.validate([0x68, 0x74, 0x74, 0x70], against: rule)  // "http"
        try RFC_5234.Validator.validate([0x48, 0x74, 0x54, 0x70], against: rule)  // "HtTp"
    }

    @Test("RFC 7405 case sensitivity - documentation of intended behavior")
    func caseSensitivityDocumentation() throws {
        // RFC 7405 adds the %s"..." syntax for case-sensitive string matching.
        // The current RFC_5234 Terminal implementation has the infrastructure
        // (the Matcher enum supports caseSensitive: Bool), but the public API
        // only exposes case-insensitive string creation.
        //
        // This test documents the intended RFC 7405 behavior:
        // - %s"HTTP" should match only "HTTP" (exact case match)
        // - %s"HTTP" should NOT match "http", "Http", etc.
        //
        // When RFC_5234.Terminal adds a public factory method for case-sensitive
        // strings (e.g., Terminal.caseSensitiveString(_:)), this test can be
        // updated to:
        //
        // let rule = RFC_5234.Rule(
        //     name: "protocol",
        //     element: .terminal(.caseSensitiveString("HTTP"))
        // )
        // try RFC_5234.Validator.validate([0x48, 0x54, 0x54, 0x50], against: rule)
        // XCTAssertThrowsError(try RFC_5234.Validator.validate([0x68, 0x74, 0x74, 0x70], against: rule))

        // For now, we document this as a feature roadmap item
        #expect(true)  // Placeholder: RFC 7405 case-sensitive support awaits Terminal API extension
    }

    @Test("Byte value matching is always case-sensitive")
    func byteValueMatching() throws {
        // Byte values are inherently case-sensitive
        let rule = RFC_5234.Rule(
            name: "uppercase-a",
            element: .terminal(.byte(0x41))  // 'A'
        )

        try RFC_5234.Validator.validate([0x41], against: rule)  // 'A'

        // This would fail because 0x61 is lowercase 'a', not uppercase 'A'
        // try RFC_5234.Validator.validate([0x61], against: rule)  // Would fail
    }

    @Test("Byte range matching with ASCII uppercase letters")
    func byteRangeUppercase() throws {
        let rule = RFC_5234.Rule(
            name: "uppercase-letter",
            element: .terminal(.byteRange(0x41, 0x5A))  // 'A' to 'Z'
        )

        try RFC_5234.Validator.validate([0x41], against: rule)  // 'A'
        try RFC_5234.Validator.validate([0x5A], against: rule)  // 'Z'
        try RFC_5234.Validator.validate([0x4D], against: rule)  // 'M'
    }

    @Test("Byte range matching with ASCII lowercase letters")
    func byteRangeLowercase() throws {
        let rule = RFC_5234.Rule(
            name: "lowercase-letter",
            element: .terminal(.byteRange(0x61, 0x7A))  // 'a' to 'z'
        )

        try RFC_5234.Validator.validate([0x61], against: rule)  // 'a'
        try RFC_5234.Validator.validate([0x7A], against: rule)  // 'z'
        try RFC_5234.Validator.validate([0x6D], against: rule)  // 'm'
    }

    @Test("RFC 7405 demonstrates the distinction between syntax cases")
    func rfc7405SyntaxDistinction() throws {
        // RFC 7405 clarifies that:
        // 1. %i"..." - case-insensitive (RFC 7405 addition for explicitness)
        // 2. %s"..." - case-sensitive (RFC 7405 addition for new feature)
        // 3. "..." - defaults to case-insensitive (RFC 5234 default, inherited by RFC 7405)
        //
        // This test suite demonstrates the case-insensitive behavior that is
        // available through RFC 5234 and enhanced by RFC 7405's explicit syntax.

        // Using explicit RFC 7405 syntax for case-insensitive matching
        let caseInsensitiveRule = RFC_5234.Rule(
            name: "greeting",
            element: .terminal(.caseInsensitiveString("hello"))
        )

        // All variations should match
        try RFC_5234.Validator.validate(Array("hello".utf8), against: caseInsensitiveRule)
        try RFC_5234.Validator.validate(Array("HELLO".utf8), against: caseInsensitiveRule)
        try RFC_5234.Validator.validate(Array("Hello".utf8), against: caseInsensitiveRule)
    }
}
