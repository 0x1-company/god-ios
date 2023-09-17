import SwiftUI

public struct LabeledButton: View {
  let action: () -> Void
  let titleKey: String
  let systemImage: String

  public init(
    _ titleKey: String,
    systemImage: String,
    action: @escaping () -> Void
  ) {
    self.titleKey = titleKey
    self.systemImage = systemImage
    self.action = action
  }

  public var body: some View {
    Button(action: action) {
      Label(titleKey, systemImage: systemImage)
        .frame(height: 50)
        .frame(maxWidth: .infinity)
    }
  }
}

struct LabeledButton_Previews: PreviewProvider {
  static var previews: some View {
    LabeledButton(
      "Logout",
      systemImage: "rectangle.portrait.and.arrow.right",
      action: {}
    )
    .padding()
    .previewLayout(.sizeThatFits)
  }
}
