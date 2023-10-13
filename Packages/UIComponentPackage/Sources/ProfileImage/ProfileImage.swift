import CachedAsyncImage
import NameImage
import Styleguide
import SwiftUI

public struct ProfileImage: View {
  let urlString: String
  let name: String
  let size: CGFloat

  public init(urlString: String, name: String, size: CGFloat) {
    self.urlString = urlString
    self.name = name
    self.size = size
  }

  public var body: some View {
    CachedAsyncImage(url: URL(string: urlString), urlCache: .shared) { phase in
      switch phase {
      case let .success(image):
        image
          .resizable()
          .aspectRatio(contentMode: .fill)
          .frame(width: size, height: size)
          .clipShape(Circle())

      case .failure:
        NameImage(name: name, size: size)

      default:
        RoundedRectangle(cornerRadius: size / 2, style: .circular)
          .fill(Color.godBackgroundWhite)
          .frame(width: size, height: size)
          .overlay {
            ProgressView()
              .progressViewStyle(.circular)
          }
      }
    }
  }
}
