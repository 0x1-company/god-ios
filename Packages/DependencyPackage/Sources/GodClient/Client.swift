import God
import Apollo

public struct GodClient: Sendable {
  public var updateUsername: @Sendable (God.UpdateUsernameInput) async throws -> GraphQLResult<God.UpdateUsernameMutation.Data>
  public var updateUserProfile: @Sendable (God.UpdateUserProfileInput) async throws -> GraphQLResult<God.UpdateUserProfileMutation.Data>
  public var createUserBlock: @Sendable (God.CreateUserBlockInput) async throws -> GraphQLResult<God.CreateUserBlockMutation.Data>
  public var createUserHide: @Sendable (God.CreateUserHideInput) async throws -> GraphQLResult<God.CreateUserHideMutation.Data>
  public var createUser: @Sendable (God.CreateUserInput) async throws -> GraphQLResult<God.CreateUserMutation.Data>
  public var user: @Sendable (God.UserWhere) -> AsyncThrowingStream<God.UserQuery.Data, Error>
  public var currentUser: @Sendable () -> AsyncThrowingStream<God.CurrentUserQuery.Data, Error>

  public var createFriendRequest: @Sendable (God.CreateFriendRequestInput) async throws -> GraphQLResult<God.CreateFriendRequestMutation.Data>
  public var approveFriendRequest: @Sendable (God.ApproveFriendRequestInput) async throws -> GraphQLResult<God.ApproveFriendRequestMutation.Data>

  public var store: @Sendable () -> AsyncThrowingStream<God.StoreQuery.Data, Error>
}
