import SwiftUI

public struct FullScreenActionView: View {
  let action: () -> Void

  public var body: some View {
    VStack(spacing: 24) {
      Text("Get more\n friends to play")
        .font(.title2)
        .foregroundColor(Color.white)
        .multilineTextAlignment(.center)
      
      Button(action: action) {
        Text("Share the app")
          .bold()
          .frame(height: 56)
          .padding(.horizontal, 32)
          .background(Color.white)
          .foregroundColor(Color.black)
          .clipShape(Capsule())
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.orange)
  }
}

struct FullScreenActionViewPreviews: PreviewProvider {
  static var previews: some View {
    FullScreenActionView(action: {})
  }
}
