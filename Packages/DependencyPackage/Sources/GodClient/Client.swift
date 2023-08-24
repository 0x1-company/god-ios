import God

public struct GodClient: Sendable {
  public var updateUsername: @Sendable (God.UpdateUsernameInput) async throws -> God.UpdateUsernameMutation.Data
  public var updateUserProfile: @Sendable (God.UpdateUserProfileInput) async throws -> God.UpdateUserProfileMutation.Data
  public var store: @Sendable () -> AsyncThrowingStream<God.StoreQuery.Data, Error>
}
