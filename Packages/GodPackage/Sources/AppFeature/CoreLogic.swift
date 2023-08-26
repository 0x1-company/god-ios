import ComposableArchitecture
import Build
import FirestoreClient
import FirebaseAuthClient

public struct CoreLogic: Reducer {
  
  @Dependency(\.build) var build
  @Dependency(\.openURL) var openURL
  @Dependency(\.firestore) var firestore
  @Dependency(\.firebaseAuth) var firebaseAuth
  
  public func reduce(
    into state: inout AppReducer.State,
    action: AppReducer.Action
  ) -> Effect<AppReducer.Action> {
    switch action {
    case .appDelegate(.delegate(.didFinishLaunching)):
      enum CancelID { case effect }
      return .run { send in
        for try await config in try await firestore.config() {
          await send(.configResponse(.success(config)), animation: .default)
        }
      } catch: { error, send in
        await send(.configResponse(.failure(error)), animation: .default)
      }
      .cancellable(id: CancelID.effect)

    case let .appDelegate(.configurationForConnecting(.some(shortcutItem))):
      let type = shortcutItem.type
      return .run { send in
        await send(.quickAction(type))
      }

    case let .sceneDelegate(.shortcutItem(shortcutItem)):
      let type = shortcutItem.type
      return .run { send in
        await send(.quickAction(type))
      }

    case let .quickAction(key):
      guard let url = state.quickActionURLs[key] else {
        return .none
      }
      return .run { _ in
        await openURL(url)
      }

    case let .configResponse(.success(config)):
      let shortVersion = build.bundleShortVersion()
      if config.isForceUpdate(shortVersion) {
        state.view = .forceUpdate()
      }
      if config.isMaintenance {
        state.view = .maintenance()
      }
      if firebaseAuth.currentUser() == nil {
        state.view = .onboard()
      }
      return .none

    case let .configResponse(.failure(error)):
      print(error)
      return .none
      
    default:
      return .none
    }
  }
}
