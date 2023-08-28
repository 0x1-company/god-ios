import Foundation

public enum ValidateError: Error {
  case invalidValue
  case transformError
}

public func transformToHiragana(for input: String) throws -> String {
  if validateHiragana(for: input) {
    return input
  }
  guard validateKatakana(for: input) else {
    throw ValidateError.invalidValue
  }
  guard let hiragana = (input as NSString).applyingTransform(StringTransform.hiraganaToKatakana, reverse: true) else {
    throw ValidateError.transformError
  }
  return hiragana
}
