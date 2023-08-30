import Apollo
import God

public struct GodClient: Sendable {
  public var updateUsername: @Sendable (God.UpdateUsernameInput) async throws -> God.UpdateUsernameMutation.Data
  public var updateUserProfile: @Sendable (God.UpdateUserProfileInput) async throws -> God.UpdateUserProfileMutation.Data
  public var createUserBlock: @Sendable (God.CreateUserBlockInput) async throws -> God.CreateUserBlockMutation.Data
  public var createUserHide: @Sendable (God.CreateUserHideInput) async throws -> God.CreateUserHideMutation.Data
  public var createUser: @Sendable (God.CreateUserInput) async throws -> God.CreateUserMutation.Data
  public var user: @Sendable (God.UserWhere) -> AsyncThrowingStream<God.UserQuery.Data, Error>
  public var currentUser: @Sendable () -> AsyncThrowingStream<God.CurrentUserQuery.Data, Error>

  public var createFriendRequest: @Sendable (God.CreateFriendRequestInput) async throws -> God.CreateFriendRequestMutation.Data
  public var approveFriendRequest: @Sendable (God.ApproveFriendRequestInput) async throws -> God.ApproveFriendRequestMutation.Data

  public var store: @Sendable () -> AsyncThrowingStream<God.StoreQuery.Data, Error>
}

extension GodClient {
  public struct GodServerError: Error {
    public let message: String
    public let extensions: [String : Any]
    public var code: GodServerErrorCode? {
      return extensions["code"] as? GodServerErrorCode
    }
    
    public init(
      message: String,
      extensions: [String : Any]
    ) {
      self.message = message
      self.extensions = extensions
    }
    
    public enum GodServerErrorCode: String {
      case badUserInput = "BAD_USER_INPUT"
      case forbidden = "FORBIDDEN"
      case unauthenticated = "UNAUTHENTICATED"
      case `internal` = "INTERNAL"
    }
  }
}
