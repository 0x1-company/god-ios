import ButtonStyles
import SwiftUI

public struct ActionSheet<Actions: View>: View {
  let title: LocalizedStringKey
  let description: LocalizedStringKey?
  let actions: () -> Actions
  let onDismiss: () -> Void
  
  public init(
    title: LocalizedStringKey,
    description: LocalizedStringKey?,
    actions: @escaping () -> Actions,
    onDismiss: @escaping () -> Void
  ) {
    self.title = title
    self.description = description
    self.actions = actions
    self.onDismiss = onDismiss
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
        Text("Close", bundle: .module)
          .bold()
          .foregroundColor(.black)
          .frame(height: 48)
          .frame(maxWidth: .infinity)
          .overlay(
            RoundedRectangle(cornerRadius: 24)
              .stroke(Color.black, lineWidth: 1)
          )
      }
      .buttonStyle(HoldDownButtonStyle())
    }
    .padding(.horizontal, 16)
  }
}

#Preview {
  ActionSheet(
    title: "Add my school to my profile",
    description: "For help with this, send us an email\nand we will get back to you right away.",
    actions: {
      HStack {
        
      }
    },
    onDismiss: {}
  )
}
