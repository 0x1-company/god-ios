import Styleguide
import SwiftUI

struct ShareStoriesButtonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .font(.system(.title3, design: .rounded, weight: .bold))
      .frame(height: 56)
      .frame(maxWidth: .infinity)
      .foregroundStyle(Color.white)
      .background(
        LinearGradient(
          colors: [Color(0xFFFF_613B), Color(0xFFD6_0E9B)],
          startPoint: UnitPoint(x: 0, y: 0),
          endPoint: UnitPoint(x: 1, y: 1)
        )
      )
      .clipShape(Capsule())
      .shadow(color: .black.opacity(0.14), radius: 2, x: 0, y: 1)
      .shadow(color: .black.opacity(0.12), radius: 2, x: 0, y: 0)
      .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
      .animation(.default, value: configuration.isPressed)
  }
}

struct SeeWhoSentItButtonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .font(.system(.title3, design: .rounded, weight: .bold))
      .frame(height: 56)
      .frame(maxWidth: .infinity)
      .foregroundStyle(.black)
      .background(
        LinearGradient(
          colors: [Color(0xFFE8_B423), Color(0xFFF5_D068)],
          startPoint: UnitPoint(x: 0, y: 0),
          endPoint: UnitPoint(x: 1, y: 1)
        )
      )
      .clipShape(Capsule())
      .shadow(color: .black.opacity(0.14), radius: 2, x: 0, y: 1)
      .shadow(color: .black.opacity(0.12), radius: 2, x: 0, y: 0)
      .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
      .animation(.default, value: configuration.isPressed)
  }
}
