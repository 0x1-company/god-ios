import SwiftUI

struct Step3View: View {
  var body: some View {
    VStack(spacing: 24) {
      Image(ImageResource.bustsInSilhouette)
        .resizable()
        .frame(width: 40, height: 40)

      Text("If the choice is too subtle. Add a friend!", bundle: .module)
        .font(.system(.title, design: .rounded, weight: .bold))

      Text("The Add Friend screen is on the leftmost tab!", bundle: .module)
        .font(.system(.headline, design: .rounded))
    }
    .padding(.horizontal, 56)
    .foregroundStyle(Color.white)
  }
}
