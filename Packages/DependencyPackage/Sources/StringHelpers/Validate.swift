import Foundation

public func validateHiragana(for input: String) -> Bool {
  let hiraganaCharacterSet = CharacterSet(charactersIn: "\u{3041}"..."\u{3096}")
  return input.rangeOfCharacter(from: hiraganaCharacterSet.inverted) == nil
}

public func validateKatakana(for input: String) -> Bool {
  let katakanaCharacterSet = CharacterSet(charactersIn: "\u{30A0}"..."\u{30FF}")
  return input.rangeOfCharacter(from: katakanaCharacterSet.inverted) == nil
}
