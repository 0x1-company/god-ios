import Photos
import UIKit
import Dependencies

extension PhotosClient: DependencyKey {
  public static let liveValue = Self(
    requestImage: { asset, targetSize, contentMode, options in
      AsyncStream { continuation in
        PHImageManager.default().requestImage(
          for: asset,
          targetSize: targetSize,
          contentMode: contentMode,
          options: options,
          resultHandler: { image, metadata in
            continuation.yield((image, metadata))
          }
        )
        continuation.finish()
      }
    }
  )
}
