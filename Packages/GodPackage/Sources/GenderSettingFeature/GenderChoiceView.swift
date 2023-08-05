import SwiftUI

public struct GenderChoiceView: View {
  let gender: String
  let action: () -> Void

  public init(
    _ gender: String,
    action: @escaping () -> Void
  ) {
    self.gender = gender
    self.action = action
  }

  public var body: some View {
    Button(action: action) {
      VStack(spacing: 4) {
        Color.blue
          .frame(width: 120, height: 120)
          .cornerRadius(12)

        Text(gender)
          .foregroundColor(Color.white)
      }
    }
  }
}

struct GenderChoiceViewPreviews: PreviewProvider {
  static var previews: some View {
    GenderChoiceView("Boy", action: {})
      .previewLayout(.sizeThatFits)
      .background(Color.god.service)
  }
}
