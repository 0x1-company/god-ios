import ComposableArchitecture
import God
import GodClient
import os

public struct CurrentUserLogic: Reducer {
  @Dependency(\.godClient.currentUser) var currentUser

  public func reduce(
    into state: inout AppLogic.State,
    action: AppLogic.Action
  ) -> Effect<AppLogic.Action> {
    switch action {
    case .appDelegate(.delegate(.didFinishLaunching)):
      enum Cancel { case id }
      return .run { send in
        for try await data in currentUser() {
          await send(.currentUserResponse(.success(data.currentUser)))
        }
      } catch: { error, send in
        await send(.currentUserResponse(.failure(error)))
      }
      .cancellable(id: Cancel.id)

    case let .currentUserResponse(.success(user)):
      state.account.currentUser = user
      return .none

    case let .currentUserResponse(.failure(error)):
      state.account.currentUser = nil
      return .none

    default:
      return .none
    }
  }
}
