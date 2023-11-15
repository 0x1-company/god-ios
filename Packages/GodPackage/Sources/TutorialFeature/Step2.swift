import SwiftUI

struct Step2View: View {
  var body: some View {
    VStack(spacing: 24) {
      Image(ImageResource.speechBalloon)
        .resizable()
        .frame(width: 40, height: 40)
      
      Text("The perfect fit for your question. Choose a friend!", bundle: .module)
        .font(.system(.title, design: .rounded, weight: .bold))
      
      Text("It'll show up 12 times in a row. Send a star to someone you're interested in. You might be able to appeal to them...?", bundle: .module)
        .font(.system(.headline, design: .rounded))
    }
    .padding(.horizontal, 56)
    .foregroundStyle(Color.white)
  }
}
