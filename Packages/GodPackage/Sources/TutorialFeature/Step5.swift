import Styleguide
import SwiftUI

struct Step5View: View {
  var body: some View {
    VStack(spacing: 40) {
      VStack(spacing: 24) {
        VStack(spacing: 8) {
          Image(systemName: "shuffle")
            .resizable()
            .frame(width: 28, height: 28)
            .foregroundStyle(Color.godYellow)
          Text("If you want to choose another friend You can shuffle your friends.", bundle: .module)
            .font(.system(.headline, design: .rounded))
        }

        VStack(spacing: 8) {
          Image(systemName: "forward.fill")
            .resizable()
            .frame(width: 28, height: 28)
            .foregroundStyle(Color.godYellow)
          Text("If you don't want to answer a question You can skip it.", bundle: .module)
            .font(.system(.headline, design: .rounded))
        }

        VStack(spacing: 8) {
          Image(ImageResource.coin)
            .resizable()
            .frame(width: 28, height: 28)
          Text("Answer questions and use coins to You can purchase items", bundle: .module)
            .font(.system(.headline, design: .rounded))
        }
      }
    }
    .foregroundStyle(Color.white)
    .multilineTextAlignment(.center)
  }
}

#Preview {
  Step5View()
    .background(Color.black.opacity(0.9))
}
