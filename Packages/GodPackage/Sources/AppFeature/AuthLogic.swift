import ComposableArchitecture
import FirebaseAuthClient

public struct AuthLogic: Reducer {
  @Dependency(\.firebaseAuth.addStateDidChangeListener) var addStateDidChangeListener

  public func reduce(
    into state: inout AppReducer.State,
    action: AppReducer.Action
  ) -> Effect<AppReducer.Action> {
    switch action {
    case .appDelegate(.delegate(.didFinishLaunching)):
      enum CancelID { case effect }
      return .run { send in
        for await user in addStateDidChangeListener() {
          await send(.authUserResponse(.success(user)))
        }
      } catch: { error, send in
        await send(.authUserResponse(.failure(error)))
      }
      .cancellable(id: CancelID.effect)
      
    case let .authUserResponse(.success(authUser)):
      state.authUser = authUser
      return .none

    case let .authUserResponse(.failure(error)):
      print(error)
      state.authUser = nil
      return .none
      
    default:
      return .none
    }
  }
}
