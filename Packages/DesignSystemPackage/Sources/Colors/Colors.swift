import SwiftUI
import ColorHex

public extension Color {
  static let god = Colors()
}

public struct Colors {
  public let whiteBackground = Color.white
  public let blackBackground = Color(0xFF1E1E1E)
  public let secondaryBackground = Color(0xFFFA_FAFA)
  public let separator = Color(uiColor: UIColor.separator)
  public let orange = Color(0xFFED6C43)
}
