import Styleguide
import SwiftUI

public struct StoriesButton: View {
  let action: () -> Void
  public var body: some View {
    Button(action: action) {
      Text("Share Stories", bundle: .module)
        .foregroundStyle(Color.white)
        .font(.system(.title3, design: .rounded, weight: .heavy))
        .frame(height: 54)
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.2))
        .clipShape(Capsule())
        .overlay(alignment: .leading) {
          Image(ImageResource.instagram)
            .resizable()
            .aspectRatio(1, contentMode: .fit)
            .frame(width: 32, height: 32)
            .padding(.leading, 16)
        }
    }
    .buttonStyle(HoldDownButtonStyle())
  }
}

#Preview {
  Color.godBlue
    .overlay {
      StoriesButton(action: {})
        .padding()
    }
}
