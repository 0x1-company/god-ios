import ButtonStyles
import SwiftUI

struct IconButton: View {
  let title: LocalizedStringKey
  let name: String
  let action: () -> Void

  init(
    _ title: LocalizedStringKey,
    name: String,
    action: @escaping () -> Void
  ) {
    self.title = title
    self.name = name
    self.action = action
  }

  var body: some View {
    Button(action: action) {
      Text(title)
        .frame(height: 54)
        .frame(maxWidth: .infinity)
        .foregroundColor(Color.black)
        .overlay(alignment: .leading) {
          Image(name, bundle: .module)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 32, height: 32)
            .clipped()
        }
        .padding(.horizontal, 16)
        .background(Color.white)
        .clipShape(Capsule())
        .shadow(color: .black.opacity(0.1), radius: 10)
    }
    .buttonStyle(HoldDownButtonStyle())
  }
}
