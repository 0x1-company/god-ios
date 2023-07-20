import SwiftUI

public struct CornerRadiusBorderButtonStyle: ButtonStyle {
  public init() {}
  public func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .overlay(
        RoundedRectangle(cornerRadius: 16)
          .stroke(Color(uiColor: .separator), lineWidth: 1)
      )
  }
}
