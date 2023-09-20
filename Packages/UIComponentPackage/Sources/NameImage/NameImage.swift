import SwiftUI
import Colors

public struct NameImage: View {
  public var body: some View {
    Text("KK")
      .bold()
      .frame(width: 42, height: 42)
      .background(Color.godBackgroundWhite)
      .foregroundStyle(Color.godTextSecondaryLight)
      .clipShape(Circle())
  }
}

#Preview {
  NameImage()
}
