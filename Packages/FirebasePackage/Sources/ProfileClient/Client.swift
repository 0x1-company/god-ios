public struct ProfileClient {
  public var user: @Sendable (_ uid: String) async throws -> AsyncThrowingStream<User, Error>
}

public extension ProfileClient {
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
