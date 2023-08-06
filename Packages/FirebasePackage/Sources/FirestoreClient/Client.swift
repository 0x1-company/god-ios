public struct FirestoreClient {
  public var config: () async throws -> AsyncThrowingStream<Config, Error>
}

public struct Config: Codable {
  public let isMaintenance: Bool
  public let minimumSupportedAppVersion: String
  
  public init(isMaintenance: Bool, minimumSupportedAppVersion: String) {
    self.isMaintenance = isMaintenance
    self.minimumSupportedAppVersion = minimumSupportedAppVersion
  }
}
