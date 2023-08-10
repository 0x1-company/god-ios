public struct FirestoreClient {
  public var config: () async throws -> AsyncThrowingStream<Config, Error>
}

public extension FirestoreClient {
  struct Config: Codable, Equatable {
    public let isMaintenance: Bool
    public let minimumSupportedAppVersion: String

    public init(isMaintenance: Bool, minimumSupportedAppVersion: String) {
      self.isMaintenance = isMaintenance
      self.minimumSupportedAppVersion = minimumSupportedAppVersion
    }

    public func isForceUpdate(_ packageVersion: String) -> Bool {
      minimumSupportedAppVersion > packageVersion
    }
  }
}
