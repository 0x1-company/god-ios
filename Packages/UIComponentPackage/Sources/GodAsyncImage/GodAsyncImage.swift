import SwiftUI
import Kingfisher

public struct GodAsyncImage: View {
  let url: URL?
  
  public init(url: URL?) {
    self.url = url
  }
  
  public var body: some View {
//    KFImage.url(url)
//      .placeholder(placeholderImage)
//      .setProcessor(processor)
//      .loadDiskFileSynchronously()
//      .cacheMemoryOnly()
//      .fade(duration: 0.25)
//      .lowDataModeSource(.network(lowResolutionURL))
//      .onProgress { receivedSize, totalSize in  }
//      .onSuccess { result in  }
//      .onFailure { error in }
    KFImage.url(url)
      .loadDiskFileSynchronously()
      .cacheMemoryOnly()
  }
}
