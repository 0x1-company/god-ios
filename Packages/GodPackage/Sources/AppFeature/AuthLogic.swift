import ComposableArchitecture
import FirebaseAuthClient

public struct AuthLogic: Reducer {
  @Dependency(\.firebaseAuth.addStateDidChangeListener) var addStateDidChangeListener

  public func reduce(
    into state: inout AppLogic.State,
    action: AppLogic.Action
  ) -> Effect<AppLogic.Action> {
    switch action {
    case .appDelegate(.delegate(.didFinishLaunching)):
      enum Cancel { case id }
      return .run { send in
        for await user in addStateDidChangeListener() {
          await send(.authUserResponse(.success(user)))
        }
      } catch: { error, send in
        await send(.authUserResponse(.failure(error)))
      }
      .cancellable(id: Cancel.id)

    case let .authUserResponse(.success(authUser)):
      state.account.authUser = authUser
      return .none

    case .authUserResponse(.failure):
      state.account.authUser = nil
      return .none

    default:
      return .none
    }
  }
}
