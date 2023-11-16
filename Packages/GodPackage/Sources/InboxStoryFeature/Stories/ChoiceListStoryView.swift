import Styleguide
import SwiftUI

public struct ChoiceListStoryView: View {
  public init() {}

  public var body: some View {
    VStack(spacing: 0) {
      ChoiceListSticker(
        questionText: "Your ideal study buddy"
      )
    }
    .padding(.horizontal, 48)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(
      LinearGradient(
        colors: [
          Color(0xFFB394FF),
          Color(0xFFFFA3E5),
          Color(0xFFFFE39B),
        ],
        startPoint: UnitPoint(x: 0.5, y: 0.0),
        endPoint: UnitPoint(x: 0.5, y: 1.0)
      )
    )
    .overlay(alignment: .bottom) {
      VStack(spacing: 4) {
        Image(ImageResource.icon)
        Text("See who likes you - God", bundle: .module)
          .font(.system(.body, design: .rounded, weight: .medium))
      }
    }
  }
}

#Preview {
  ChoiceListStoryView()
}
