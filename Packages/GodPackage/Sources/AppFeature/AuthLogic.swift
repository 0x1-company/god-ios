import ComposableArchitecture
import FirebaseAuthClient

@Reducer
public struct AuthLogic {
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

    case let .authUserResponse(.success(user)):
      state.account.authUser = .success(user)
      return .none

    case let .authUserResponse(.failure(error)):
      state.account.authUser = .failure(error)
      return .none

    default:
      return .none
    }
  }
}
