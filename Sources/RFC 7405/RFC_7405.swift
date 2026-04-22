/// RFC 7405: Case-Sensitive String Support in ABNF
///
/// RFC 7405 extends RFC 5234 (ABNF) to add case-sensitive string literals.
/// While RFC 5234 defines string literals as case-insensitive by default,
/// RFC 7405 introduces the %s"..." syntax for case-sensitive matching and
/// explicitly defines %i"..." for case-insensitive matching.
///
/// ## Key Concepts
///
/// - Case-sensitive strings: `%s"..."` matches exact case only
/// - Case-insensitive strings: `%i"..."` or `"..."` matches any case
///
/// ## Example
///
/// ```swift
/// // Case-insensitive (RFC 5234 default, RFC 7405 explicit)
/// let rule1 = RFC_5234.Rule(
///     name: "protocol",
///     element: .terminal(.caseInsensitiveString("HTTP"))
/// )
/// // Matches: "HTTP", "http", "Http", etc.
/// ```
///
/// ## See Also
///
/// - [RFC 7405](https://www.rfc-editor.org/rfc/rfc7405)
/// - ``RFC_5234``
public enum RFC_7405 {}
