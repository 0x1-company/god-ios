import Build
import ComposableArchitecture
import FirebaseAuthClient
import FirestoreClient

public struct CoreLogic: Reducer {
  @Dependency(\.build) var build
  @Dependency(\.openURL) var openURL
  @Dependency(\.firestore) var firestore
  @Dependency(\.firebaseAuth) var firebaseAuth

  public func reduce(
    into state: inout AppLogic.State,
    action: AppLogic.Action
  ) -> Effect<AppLogic.Action> {
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
