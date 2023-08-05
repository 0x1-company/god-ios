import ColorHex
import SwiftUI

public extension Color {
  static let god = Colors()
}

public struct Colors {
  public let separator = Color(uiColor: UIColor.separator)

  public let black = Color("black", bundle: .module)
  public let service = Color("service", bundle: .module)
  public let textPrimary = Color("text-primary", bundle: .module)
  public let textSecondaryDark = Color("text-secondary-dark", bundle: .module)
  public let textSecondaryLight = Color("text-secondary-light", bundle: .module)
  public let white = Color("white", bundle: .module)
}
