import ComposableArchitecture
import God
import GodClient
import os

public struct CurrentUserLogic: Reducer {
  private let logger = Logger(subsystem: "jp.godapp", category: "CurrentUserLogic")

  @Dependency(\.godClient.currentUser) var currentUser

  public func reduce(
    into state: inout AppReducer.State,
    action: AppReducer.Action
  ) -> Effect<AppReducer.Action> {
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
      logger.error("""
      function: \(#function)
      line: \(#line)
      description: \(error.localizedDescription)
      """)
      state.account.currentUser = nil
      return .none

    default:
      return .none
    }
  }
}
