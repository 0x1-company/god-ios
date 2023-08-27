import ComposableArchitecture
import God
import GodClient

public struct OnboardStreamLogic: Reducer {
  @Dependency(\.godClient.currentUser) var currentUser

  public func reduce(
    into state: inout OnboardReducer.State,
    action: OnboardReducer.Action
  ) -> Effect<OnboardReducer.Action> {
    switch action {
    case .onTask:
      return .run { send in
        for try await data in currentUser() {
          await send(.currentUserResponse(.success(data.currentUser)))
        }
      } catch: { error, send in
        await send(.currentUserResponse(.failure(error)))
      }
      
    case let .currentUserResponse(.success(user)):
      state.currentUser = user
      return .none
      
    case .currentUserResponse(.failure):
      return .none
      
    default:
      return .none
    }
  }
}
