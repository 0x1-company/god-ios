import SwiftUI

struct Step4View: View {
  var body: some View {
    VStack(spacing: 24) {
      Image(ImageResource.locked)
        .resizable()
        .frame(width: 40, height: 40)

      Text("Your personal information is Securely managed", bundle: .module)
        .font(.system(.title, design: .rounded, weight: .bold))

      Text("Your name, school name, and other important information is only to connect with friends.", bundle: .module)
        .font(.system(.headline, design: .rounded))
    }
    .padding(.horizontal, 56)
    .foregroundStyle(Color.white)
  }
}
