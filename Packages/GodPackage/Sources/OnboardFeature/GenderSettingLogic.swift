import ComposableArchitecture
import God
import GodClient

public struct GenderSettingLogic: Reducer {
  @Dependency(\.godClient.updateUserProfile) var updateUserProfile

  public func reduce(
    into state: inout OnboardReducer.State,
    action: OnboardReducer.Action
  ) -> Effect<OnboardReducer.Action> {
    switch action {
    case let .genderChanged(gender):
      let input = God.UpdateUserProfileInput(
        gender: .init(gender)
      )
      return .run { _ in
        _ = try await self.updateUserProfile(input)
      }
    default:
      return .none
    }
  }
}
