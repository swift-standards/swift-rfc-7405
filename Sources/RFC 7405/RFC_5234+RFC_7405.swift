// RFC_5234+RFC_7405.swift
// swift-rfc-7405
//
// RFC 7405 Extensions to RFC 5234

@_spi(RFC_7405) import RFC_5234

extension RFC_5234.Terminal {
    /// Creates an explicitly case-insensitive string literal terminal (%i"..." syntax).
    ///
    /// RFC 7405 introduces the `%i` prefix to explicitly mark strings as case-insensitive.
    /// This is equivalent to the default RFC 5234 behavior (bare `"..."` strings).
    ///
    /// ## Example
    ///
    /// ```swift
    /// let rule = RFC_5234.Rule(
    ///     name: "protocol",
    ///     element: .terminal(.caseInsensitiveString("HTTP"))
    /// )
    /// // Matches: "HTTP", "http", "Http", "hTTP", etc.
    /// ```
    ///
    /// ## RFC 7405 Syntax
    ///
    /// Both forms are equivalent:
    /// - `%i"HTTP"` - Explicit case-insensitive (RFC 7405)
    /// - `"HTTP"` - Implicit case-insensitive (RFC 5234)
    ///
    /// - Parameter string: The string to match (case-insensitive)
    /// - Returns: A terminal that performs case-insensitive matching
    public static func caseInsensitiveString(_ string: String) -> Self {
        // Delegate to RFC 5234's default string method
        Self.string(string)
    }
}

// Note: caseSensitiveString is defined in RFC_5234.Terminal
// RFC 7405 %s"..." syntax is implemented there.
