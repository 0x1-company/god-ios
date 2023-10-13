import Styleguide
import SwiftUI

struct IconButton: View {
  let title: LocalizedStringKey
  let image: ImageResource
  let action: () -> Void

  init(
    _ title: LocalizedStringKey,
    image: ImageResource,
    action: @escaping () -> Void
  ) {
    self.title = title
    self.image = image
    self.action = action
  }

  var body: some View {
    Button(action: action) {
      Text(title, bundle: .module)
        .font(.system(.headline, design: .rounded, weight: .bold))
        .frame(height: 54)
        .frame(maxWidth: .infinity)
        .foregroundColor(Color.black)
        .overlay(alignment: .leading) {
          Image(image)
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
