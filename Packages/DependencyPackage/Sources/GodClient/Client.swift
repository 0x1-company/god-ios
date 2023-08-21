import God

public struct GodClient {
  public var updateUsername: (God.UpdateUsernameInput) async throws -> God.UpdateUsernameMutation.Data
}
