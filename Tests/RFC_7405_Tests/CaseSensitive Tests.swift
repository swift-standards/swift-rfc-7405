// CaseSensitive Tests.swift
// swift-rfc-7405
//
// Tests for RFC 7405 case-sensitive strings

@_spi(RFC_7405) import RFC_5234
import RFC_7405
import Testing

@Suite("RFC_7405 - Case-Sensitive Strings (%s\"...\")")
struct CaseSensitiveStringTests {
    @Test("Case-sensitive string matches exact case")
    func caseSensitiveMatchesExact() throws {
        let rule = RFC_5234.Rule(
            name: "test",
            element: .terminal(.caseSensitiveString("aBc"))
        )

        try RFC_5234.Validator.validate([0x61, 0x42, 0x63], against: rule)  // "aBc" ✓
    }

    @Test("Case-sensitive string rejects different case")
    func caseSensitiveRejectsDifferentCase() {
        let rule = RFC_5234.Rule(
            name: "test",
            element: .terminal(.caseSensitiveString("aBc"))
        )

        // These should all fail
        #expect(throws: RFC_5234.Validator.ValidationError.self) {
            try RFC_5234.Validator.validate([0x61, 0x62, 0x63], against: rule)  // "abc"
        }
        #expect(throws: RFC_5234.Validator.ValidationError.self) {
            try RFC_5234.Validator.validate([0x41, 0x42, 0x43], against: rule)  // "ABC"
        }
        #expect(throws: RFC_5234.Validator.ValidationError.self) {
            try RFC_5234.Validator.validate([0x41, 0x42, 0x63], against: rule)  // "ABc"
        }
    }

    @Test("Case-sensitive uppercase")
    func caseSensitiveUppercase() throws {
        let rule = RFC_5234.Rule(
            name: "test",
            element: .terminal(.caseSensitiveString("HTTP"))
        )

        try RFC_5234.Validator.validate([0x48, 0x54, 0x54, 0x50], against: rule)  // "HTTP" ✓

        #expect(throws: RFC_5234.Validator.ValidationError.self) {
            try RFC_5234.Validator.validate([0x68, 0x74, 0x74, 0x70], against: rule)  // "http" ✗
        }
    }

    @Test("Case-sensitive lowercase")
    func caseSensitiveLowercase() throws {
        let rule = RFC_5234.Rule(
            name: "test",
            element: .terminal(.caseSensitiveString("http"))
        )

        try RFC_5234.Validator.validate([0x68, 0x74, 0x74, 0x70], against: rule)  // "http" ✓

        #expect(throws: RFC_5234.Validator.ValidationError.self) {
            try RFC_5234.Validator.validate([0x48, 0x54, 0x54, 0x50], against: rule)  // "HTTP" ✗
        }
    }
}

@Suite("RFC_7405 - Case-Insensitive Strings (%i\"...\" and \"...\")")
struct CaseInsensitiveStringTests {
    @Test("Explicit case-insensitive (%i) matches all cases")
    func explicitCaseInsensitiveMatchesAll() throws {
        let rule = RFC_5234.Rule(
            name: "test",
            element: .terminal(.caseInsensitiveString("abc"))
        )

        // All case variations should match
        try RFC_5234.Validator.validate([0x61, 0x62, 0x63], against: rule)  // "abc"
        try RFC_5234.Validator.validate([0x41, 0x42, 0x43], against: rule)  // "ABC"
        try RFC_5234.Validator.validate([0x41, 0x62, 0x43], against: rule)  // "AbC"
        try RFC_5234.Validator.validate([0x61, 0x42, 0x63], against: rule)  // "aBc"
    }

    @Test("Default RFC 5234 string() matches all cases")
    func defaultStringMatchesAll() throws {
        // RFC 5234 default behavior: case-insensitive
        let rule = RFC_5234.Rule(
            name: "test",
            element: .terminal(.string("abc"))
        )

        // All case variations should match
        try RFC_5234.Validator.validate([0x61, 0x62, 0x63], against: rule)  // "abc"
        try RFC_5234.Validator.validate([0x41, 0x42, 0x43], against: rule)  // "ABC"
        try RFC_5234.Validator.validate([0x41, 0x62, 0x43], against: rule)  // "AbC"
    }

    @Test("Explicit %i equals default \"...\"")
    func explicitEqualsDefault() throws {
        let explicitRule = RFC_5234.Rule(
            name: "explicit",
            element: .terminal(.caseInsensitiveString("test"))
        )

        let defaultRule = RFC_5234.Rule(
            name: "default",
            element: .terminal(.string("test"))
        )

        let testCases: [[UInt8]] = [
            [0x74, 0x65, 0x73, 0x74],  // "test"
            [0x54, 0x45, 0x53, 0x54],  // "TEST"
            [0x54, 0x65, 0x73, 0x74],  // "Test"
        ]

        for testCase in testCases {
            try RFC_5234.Validator.validate(testCase, against: explicitRule)
            try RFC_5234.Validator.validate(testCase, against: defaultRule)
        }
    }
}

@Suite("RFC_7405 - Mixed Case Sensitivity")
struct MixedCaseSensitivityTests {
    @Test("Sequence with both case-sensitive and case-insensitive")
    func mixedSequence() throws {
        // %s"GET" SP %i"http"
        let rule = RFC_5234.Rule(
            name: "test",
            element: .sequence([
                .terminal(.caseSensitiveString("GET")),  // Must be exactly "GET"
                .terminal(.byte(0x20)),  // Space
                .terminal(.caseInsensitiveString("http"))  // Can be any case
            ])
        )

        // "GET http" ✓
        try RFC_5234.Validator.validate(
            [0x47, 0x45, 0x54, 0x20, 0x68, 0x74, 0x74, 0x70],
            against: rule
        )

        // "GET HTTP" ✓ (http part is case-insensitive)
        try RFC_5234.Validator.validate(
            [0x47, 0x45, 0x54, 0x20, 0x48, 0x54, 0x54, 0x50],
            against: rule
        )

        // "get HTTP" ✗ (GET part is case-sensitive)
        #expect(throws: RFC_5234.Validator.ValidationError.self) {
            try RFC_5234.Validator.validate(
                [0x67, 0x65, 0x74, 0x20, 0x48, 0x54, 0x54, 0x50],
                against: rule
            )
        }
    }

    @Test("Alternation with different case sensitivity")
    func mixedAlternation() throws {
        // %s"POST" / %i"get"
        let rule = RFC_5234.Rule(
            name: "test",
            element: .alternation([
                .terminal(.caseSensitiveString("POST")),  // Exact "POST"
                .terminal(.caseInsensitiveString("get"))   // Any case "get"
            ])
        )

        // "POST" ✓
        try RFC_5234.Validator.validate([0x50, 0x4F, 0x53, 0x54], against: rule)

        // "get" ✓
        try RFC_5234.Validator.validate([0x67, 0x65, 0x74], against: rule)

        // "GET" ✓ (get is case-insensitive)
        try RFC_5234.Validator.validate([0x47, 0x45, 0x54], against: rule)

        // "post" ✗ (POST is case-sensitive)
        #expect(throws: RFC_5234.Validator.ValidationError.self) {
            try RFC_5234.Validator.validate([0x70, 0x6F, 0x73, 0x74], against: rule)
        }
    }
}

@Suite("RFC_7405 - Backward Compatibility")
struct BackwardCompatibilityTests {
    @Test("RFC 5234 rules still work")
    func rfc5234RulesWork() throws {
        // All RFC 5234 core rules should still work
        try RFC_5234.Validator.validate([0x35], against: RFC_5234.CoreRules.DIGIT)  // "5"
        try RFC_5234.Validator.validate([0x41], against: RFC_5234.CoreRules.ALPHA)  // "A"
        try RFC_5234.Validator.validate([0x46], against: RFC_5234.CoreRules.HEXDIG)  // "F"
    }

    @Test("Default string behavior unchanged")
    func defaultStringUnchanged() throws {
        // RFC 5234 default string behavior: case-insensitive
        // This should not change with RFC 7405
        let rule = RFC_5234.Rule(
            name: "protocol",
            element: .terminal(.string("HTTP"))
        )

        // All cases should still match (backward compatible)
        try RFC_5234.Validator.validate([0x48, 0x54, 0x54, 0x50], against: rule)  // "HTTP"
        try RFC_5234.Validator.validate([0x68, 0x74, 0x74, 0x70], against: rule)  // "http"
        try RFC_5234.Validator.validate([0x48, 0x74, 0x74, 0x70], against: rule)  // "Http"
    }
}
