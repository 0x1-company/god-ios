import SwiftUI

private func getFontName(weight: Font.Weight) -> String {
  switch weight {
  case .regular:
    return "MPLUSRounded1c-Regular"
  case .bold:
    return "MPLUSRounded1c-Bold"
  case .black:
    return "MPLUSRounded1c-Black"
  default:
    fatalError("Not found \(weight)")
  }
}

public extension Font {
  static func custom(_ style: Font.TextStyle = .body, design: Design?, weight: Font.Weight = .regular) -> Font {
    let fontName = getFontName(weight: weight)
    return Font.custom(fontName, size: style.size, relativeTo: style)
  }

  static func custom(size: CGFloat, weight: Font.Weight = .regular, design: Design?) -> Font {
    let fontName = getFontName(weight: weight)
    return Font.custom(fontName, size: size)
  }
}
