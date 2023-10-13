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
  func custom(_ style: Font.TextStyle, weight: Font.Weight = .regular) -> Font {
    let fontName = getFontName(weight: weight)
    return Font.custom(fontName, size: style.size, relativeTo: style)
  }
}
