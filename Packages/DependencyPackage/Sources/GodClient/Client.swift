import God

public struct GodClient {
  public var updateUsername: @Sendable (God.UpdateUsernameInput) async throws -> God.UpdateUsernameMutation.Data
  public var store: @Sendable () -> AsyncThrowingStream<God.StoreQuery.Data, Error>
}
