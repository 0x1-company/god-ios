public struct ProfileClient {
  public var user: @Sendable (_ uid: String) async throws -> AsyncThrowingStream<User, Error>
  public var isAvailableUsername: @Sendable (_ username: String) async throws -> Bool

  public var setDocumentData: (_ documentPath: String, _ documentData: [String: Any]) async throws -> Void
}

public extension ProfileClient {
  enum Gender: String, Codable {
    case male = "MALE"
    case female = "FEMALE"
    case other = "OTHER"
  }

  struct User: Codable, Equatable {
    public let firstName: String
    public let lastName: String
    public let username: String
    public let yearId: Int
    public let schoolId: String
    public let gender: Gender
  }

  struct UserFirestoreField: Codable, Equatable {
    public let firstName: String?
    public let lastName: String?
    public let username: String?
    public let yearId: Int?
    public let schoolId: String?
    public let gender: Gender?

    public init(
      firstName: String? = nil,
      lastName: String? = nil,
      username: String? = nil,
      yearId: Int? = nil,
      schoolId: String? = nil,
      gender: Gender? = nil
    ) {
      self.firstName = firstName
      self.lastName = lastName
      self.username = username
      self.yearId = yearId
      self.schoolId = schoolId
      self.gender = gender
    }
  }
}

public extension ProfileClient {
  func setUserProfile(uid: String, field: UserFirestoreField) async throws {
    let documentPath = "/users/\(uid)"

    var data: [String: Any] = [:]
    if let firstName = field.firstName {
      data["firstName"] = firstName
    }
    if let lastName = field.lastName {
      data["lastName"] = lastName
    }
    if let username = field.username {
      data["username"] = username
    }
    if let yearId = field.yearId {
      data["yearId"] = yearId
    }
    if let schoolId = field.schoolId {
      data["schoolId"] = schoolId
    }
    if let gender = field.gender {
      data["gender"] = gender.rawValue
    }
    try await setDocumentData(documentPath, data)
  }
}
