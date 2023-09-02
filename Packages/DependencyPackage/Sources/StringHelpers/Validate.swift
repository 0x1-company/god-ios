import Foundation

public func validateHiragana(for input: String) -> Bool {
  let hiraganaCharacterSet = CharacterSet(charactersIn: "\u{3041}" ... "\u{3096}")
  return input.rangeOfCharacter(from: hiraganaCharacterSet.inverted) == nil
}

public func validateKatakana(for input: String) -> Bool {
  let katakanaCharacterSet = CharacterSet(charactersIn: "\u{30A0}" ... "\u{30FF}")
  return input.rangeOfCharacter(from: katakanaCharacterSet.inverted) == nil
}

public func validateUsername(for username: String) -> Bool {
  let usernameRegex = try! NSRegularExpression(pattern: "^[a-zA-Z0-9_]+(?:\\.[a-zA-Z0-9_]+)*$")
  let usernameTest = NSPredicate(format: "SELF MATCHES %@", usernameRegex.pattern)
  
  if !usernameTest.evaluate(with: username) {
    return false
  }
  
  if username.count < 4 || username.count > 30 {
    return false
  }
  
  if username.contains("..") {
    return false
  }
  
  if username.hasPrefix(".") || username.hasSuffix(".") {
    return false
  }
  
  return true
}
