import God

public struct UserClient {
  public var updateUsername: (God.UpdateUsernameInput) async throws -> God.UpdateUsernameMutation.Data
}
