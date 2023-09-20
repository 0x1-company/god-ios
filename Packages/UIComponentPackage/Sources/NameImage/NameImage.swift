import Colors
import SwiftUI

public struct NameImage: View {
  let familyName: String
  let givenName: String

  var initialName: String {
    [familyName.first, givenName.first]
      .compactMap { $0 }
      .compactMap(String.init)
      .joined()
  }

  public init(familyName: String, givenName: String) {
    self.familyName = familyName
    self.givenName = givenName
  }

  public var body: some View {
    Text(initialName)
      .bold()
      .frame(width: 42, height: 42)
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
