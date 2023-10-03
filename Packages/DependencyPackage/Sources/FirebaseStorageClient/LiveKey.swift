import Dependencies
import FirebaseStorage
import Foundation

extension FirebaseStorageClient: DependencyKey {
  public static let liveValue: Self = {
    let storage = Storage.storage()
    return Self(
      upload: { path, uploadData in
        let reference = storage.reference().child(path)
        _ = try await reference.putDataAsync(uploadData, metadata: nil, onProgress: nil)
        return try await reference.downloadURL()
      }
    )
  }()
}
