import Photos
import UIKit

public struct PhotosClient: Sendable {
  public var requestImage: @Sendable (PHAsset, CGSize, PHImageContentMode, PHImageRequestOptions?) -> AsyncStream<(UIImage?, [AnyHashable: Any]?)>
}
