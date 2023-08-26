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

    default:
      return .none
    }
  }
}
