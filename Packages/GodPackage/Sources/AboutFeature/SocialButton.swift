import SwiftUI

struct SocialButton: View {
  let image: String
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      Image(image, bundle: .module)
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: 62, height: 62)
    }
  }
}
