import SwiftUI

public extension Font.TextStyle {
  var size: CGFloat {
    switch self {
    case .largeTitle:
      return 34
    case .title:
      return 28
    case .title2:
      return 22
    case .title3:
      return 20
    case .headline:
      return 17
    case .subheadline:
      return 15
    case .body:
      return 17
    case .callout:
      return 16
    case .footnote:
      return 13
    case .caption:
      return 12
    case .caption2:
      return 11
    default:
      return 0
    }
  }
}
