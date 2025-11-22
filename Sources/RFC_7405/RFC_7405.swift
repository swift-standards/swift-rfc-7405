/// RFC 7405: Case-Sensitive String Support in ABNF
///
/// RFC 7405 extends RFC 5234 (ABNF) to add case-sensitive string literals.
/// While RFC 5234 defines string literals as case-insensitive by default (e.g., "abc"),
/// RFC 7405 introduces the %s"..." syntax for case-sensitive matching and explicitly
/// defines %i"..." for case-insensitive matching.
///
/// Example:
/// ```
/// ; Case-insensitive (RFC 5234 default)
/// rule1 = "hello"  ; matches "hello", "Hello", "HELLO"
///
/// ; Case-sensitive (RFC 7405)
/// rule2 = %s"hello"  ; matches only "hello"
///
/// ; Explicit case-insensitive (RFC 7405)
/// rule3 = %i"hello"  ; matches "hello", "Hello", "HELLO"
/// ```
public enum RFC_7405 {}
