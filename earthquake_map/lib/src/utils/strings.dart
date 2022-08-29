///  Returns true when a code unit at [index] of [str] is a digit.
///
/// Source: https://stackoverflow.com/questions/25872456/dart-what-is-the-fastest-way-to-check-if-a-particular-symbol-in-a-string-is-a-d
bool isDigit(String str, int index) => (str.codeUnitAt(index) ^ 0x30) <= 9;
