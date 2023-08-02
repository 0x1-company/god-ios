import SwiftUI

public struct CornerRadiusBorderButtonStyle: ButtonStyle {
  let cornerRadius: CGFloat

  public init(cornerRadius: CGFloat = 16) {
    self.cornerRadius = cornerRadius
  }

  public func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .overlay(
        RoundedRectangle(cornerRadius: cornerRadius)
          .stroke(Color(uiColor: .separator), lineWidth: 1)
      )
  }
}
