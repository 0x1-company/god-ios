import SwiftUI

public struct HoldDownButtonStyle: ButtonStyle {
  public init() {}
  public func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
      .animation(.default, value: configuration.isPressed)
  }
}

struct HoldDownButtonStylePreviews: PreviewProvider {
  static var previews: some View {
    Button(action: {}) {
      Text("Next")
        .bold()
        .frame(height: 54)
        .frame(maxWidth: .infinity)
        .foregroundColor(.white)
        .background(Color.orange)
        .clipShape(Capsule())
    }
    .padding()
    .buttonStyle(HoldDownButtonStyle())
  }
}
