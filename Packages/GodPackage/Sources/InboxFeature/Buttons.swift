import SwiftUI

struct SeeWhoLikesYouButtonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .frame(height: 56)
      .frame(maxWidth: .infinity)
      .font(.system(.body, design: .rounded, weight: .bold))
      .foregroundStyle(.white)
      .background(Color.black)
      .clipShape(Capsule())
      .padding(.horizontal, 16)
      .padding(.top, 8)
      .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
      .animation(.default, value: configuration.isPressed)
  }
}

struct SeeWhoSentItButtonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .font(.system(.body, design: .rounded, weight: .bold))
      .frame(height: 50)
      .frame(maxWidth: .infinity)
      .foregroundColor(.white)
      .background(Color.godGray)
      .clipShape(Capsule())
      .padding(.horizontal, 16)
      .padding(.top, 8)
      .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
      .animation(.default, value: configuration.isPressed)
  }
}
