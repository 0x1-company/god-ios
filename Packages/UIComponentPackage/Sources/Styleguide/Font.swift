import SwiftUI

private func getFontName(weight: Font.Weight) -> String {
  switch weight {
  case .regular:
    return "MPLUSRounded1c-Regular"
  case .bold:
    return "MPLUSRounded1c-Bold"
  default:
    fatalError("Not found \(weight)")
  }
}

public extension Font {
  static func custom(_ style: Font.TextStyle = .body, weight: Font.Weight = .regular) -> Font {
    let fontName = getFontName(weight: weight)
    return Font.custom(fontName, size: style.size, relativeTo: style)
  }
}
