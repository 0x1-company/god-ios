import God

public struct GodClient: Sendable {
  public var updateUsername: @Sendable (God.UpdateUsernameInput) async throws -> God.UpdateUsernameMutation.Data
  public var updateUserProfile: @Sendable (God.UpdateUserProfileInput) async throws -> God.UpdateUserProfileMutation.Data
  public var createUserBlock: @Sendable (God.CreateUserBlockInput) async throws -> God.CreateUserBlockMutation.Data
  public var createUserHide: @Sendable (God.CreateUserHideInput) async throws -> God.CreateUserHideMutation.Data
  public var createUser: @Sendable (God.CreateUserInput) async throws -> God.CreateUserMutation.Data
  
  public var createFriendRequest: @Sendable (God.CreateFriendRequestInput) async throws -> God.CreateFriendRequestMutation.Data
  public var approveFriendRequest: @Sendable (God.ApproveFriendRequestInput) async throws -> God.ApproveFriendRequestMutation.Data

  public var store: @Sendable () -> AsyncThrowingStream<God.StoreQuery.Data, Error>
}
