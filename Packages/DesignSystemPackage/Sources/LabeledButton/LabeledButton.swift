import SwiftUI

public struct LabeledButton: View {
  let action: () -> Void
  let titleKey: LocalizedStringKey
  let systemImage: String
  
  public init(
    _ titleKey: LocalizedStringKey,
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
        .foregroundColor(.primary)
        .frame(height: 50)
        .frame(maxWidth: .infinity)
    }
    .overlay(
      RoundedRectangle(cornerRadius: 16)
        .stroke(Color(uiColor: .separator), lineWidth: 1)
    )
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
