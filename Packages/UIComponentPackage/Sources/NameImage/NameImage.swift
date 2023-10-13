import Styleguide
import SwiftUI

public struct NameImage: View {
  let name: String
  let size: CGFloat

  var initialName: String {
    name.prefix(2)
      .compactMap(String.init)
      .joined()
  }

  public init(
    name: String,
    size: CGFloat = 42
  ) {
    self.name = name
    self.size = size
  }

  public var body: some View {
    Text(initialName)
      .font(.system(size: size / 3, weight: .bold, design: .rounded))
      .frame(width: size, height: size)
      .background(Color.godBackgroundWhite)
      .foregroundStyle(Color.godTextSecondaryLight)
      .clipShape(Circle())
  }
}

#Preview {
  VStack {
    NameImage(name: "ともき", size: 42)
    NameImage(name: "ともき", size: 140)
    NameImage(name: "と", size: 140)
  }
}
