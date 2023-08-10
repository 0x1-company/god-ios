public struct FirestoreClient {
  public var config: () async throws -> AsyncThrowingStream<Config, Error>
  public var user: (_ uid: String) async throws -> AsyncThrowingStream<User, Error>
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
  
  struct User: Codable, Equatable {
    public let firstName: String
    public let lastName: String
    public let username: String
    public let yearId: Int
    public let schoolId: String
    public let gender: Gender
    
    public enum Gender: String, Codable {
      case boy
      case girl
      case none
    }
  }
}
