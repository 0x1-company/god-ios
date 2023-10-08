import ButtonStyles
import SwiftUI

public struct GodActionSheet<Actions: View>: View {
  let title: String
  let description: String?
  let onDismiss: () -> Void
  let actions: () -> Actions

  public init(
    title: String,
    description: String?,
    onDismiss: @escaping () -> Void,
    actions: @escaping () -> Actions
  ) {
    self.title = title
    self.description = description
    self.onDismiss = onDismiss
    self.actions = actions
  }

  public var body: some View {
    VStack(alignment: .center, spacing: 28) {
      VStack(alignment: .center, spacing: 12) {
        Text(title)
          .font(.title3)
          .bold()
        if let description {
          Text(description)
            .font(.body)
            .foregroundStyle(.secondary)
        }
      }
      .multilineTextAlignment(.center)

      actions()

      Button(action: onDismiss) {
        RoundedRectangle(cornerRadius: 24)
          .stroke(Color.black, lineWidth: 1)
          .frame(height: 48)
          .background {
            Text("Close", bundle: .module)
              .bold()
              .foregroundColor(.black)
              .frame(height: 48)
              .frame(maxWidth: .infinity)
          }
      }
      .buttonStyle(HoldDownButtonStyle())
    }
    .padding(.horizontal, 16)
  }
}

#Preview {
  GodActionSheet(
    title: "Add my school to my profile",
    description: "For help with this, send us an email\nand we will get back to you right away.",
    onDismiss: {},
    actions: {
      HStack {}
    }
  )
}
