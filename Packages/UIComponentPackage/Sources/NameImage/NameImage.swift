import Colors
import SwiftUI

public struct NameImage: View {
  let familyName: String
  let givenName: String
  let size: CGFloat

  var initialName: String {
    [familyName.first, givenName.first]
      .compactMap { $0 }
      .compactMap(String.init)
      .joined()
  }

  public init(
    familyName: String,
    givenName: String,
    size: CGFloat = 42
  ) {
    self.familyName = familyName
    self.givenName = givenName
    self.size = size
  }

  public var body: some View {
    Text(initialName)
      .bold()
      .frame(width: size, height: size)
      .background(Color.godBackgroundWhite)
      .foregroundStyle(Color.godTextSecondaryLight)
      .clipShape(Circle())
  }
}

#Preview {
  NameImage(
    familyName: "つきやま",
    givenName: "ともき"
  )
}
