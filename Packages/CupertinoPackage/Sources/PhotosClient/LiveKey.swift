import Photos
import UIKit
import Dependencies

extension PhotosClient: DependencyKey {
  public static let liveValue = Self(
    requestAuthorization: { accessLevel in
      await withCheckedContinuation { continuation in
        PHPhotoLibrary.requestAuthorization(for: accessLevel) { status in
          continuation.resume(returning: status)
        }
      }
    },
    authorizationStatus: { PHPhotoLibrary.authorizationStatus(for: $0) },
    fetchAssets: { options in
      let result = PHAsset.fetchAssets(with: options)
      var assets: [PHAsset] = []
      result.enumerateObjects { asset, _, _ in
        assets.append(asset)
      }
      return assets
    },
    requestImage: { asset, targetSize, contentMode, options in
      print("PhotosClient: requestImage")
      return AsyncStream { continuation in
        PHImageManager.default().requestImage(
          for: asset,
          targetSize: targetSize,
          contentMode: contentMode,
          options: options,
          resultHandler: { image, metadata in
            print("PhotosClient: \(image)")
            print("PhotosClient: \(metadata)")
            continuation.yield((image, metadata))
          }
        )
      }
    },
    performChanges: { try await PHPhotoLibrary.shared().performChanges($0) }
  )
}
