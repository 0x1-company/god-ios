import ComposableArchitecture
import FirebaseAuthClient
import God
import GodClient

public struct OnboardAuthLogic: Reducer {
  @Dependency(\.firebaseAuth) var firebaseAuth
  @Dependency(\.godClient) var godClient
  
  public func reduce(
    into state: inout OnboardReducer.State,
    action: OnboardReducer.Action
  ) -> Effect<OnboardReducer.Action> {
    switch action {
    default:
      return .none
    }
  }
}
