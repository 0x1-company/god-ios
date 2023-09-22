import Foundation

public struct FirebaseStorageClient {
  public var upload: (String, Data) async throws -> Void
}
