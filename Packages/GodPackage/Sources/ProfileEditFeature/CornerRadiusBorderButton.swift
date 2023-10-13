import Styleguide
import Styleguide
import SwiftUI

public struct CornerRadiusBorderButton: View {
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
      Label {
        Text(titleKey, bundle: .module)
      } icon: {
        Image(systemName: systemImage)
      }
      .frame(height: 50)
      .frame(maxWidth: .infinity)
      .overlay(
        RoundedRectangle(cornerRadius: 16)
          .stroke(Color.godSeparator, lineWidth: 1)
      )
    }
    .buttonStyle(HoldDownButtonStyle())
  }
}
