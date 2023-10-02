import SwiftUI
import Kingfisher
import NameImage

public struct ProfilePicture: View {
  let url: URL?
  let familyName: String
  let givenName: String
  let size: CGFloat
  
  public init(url: URL?, familyName: String, givenName: String, size: CGFloat) {
    self.url = url
    self.familyName = familyName
    self.givenName = givenName
    self.size = size
  }
  
  public var body: some View {
    KFImage.url(url)
      .fromMemoryCacheOrRefresh()
      .placeholder {
        NameImage(
          familyName: familyName,
          givenName: givenName,
          size: size
        )
      }
      .resizable()
      .aspectRatio(contentMode: .fill)
      .frame(width: size, height: size)
      .clipShape(Circle())
  }
}
