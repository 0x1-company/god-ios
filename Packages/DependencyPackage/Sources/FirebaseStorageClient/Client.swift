import Foundation
import FirebaseStorage

public struct FirebaseStorageClient {
  public var upload: (String, Data) async throws -> StorageMetadata
}
