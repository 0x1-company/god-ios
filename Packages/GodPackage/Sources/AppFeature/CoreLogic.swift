import Constants
import ComposableArchitecture

public struct CoreLogic: Reducer {
  @Dependency(\.openURL) var openURL

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
      guard let url = Constants.quickActionURLs[key]
      else { return .none }
      return .run { _ in
        await openURL(url)
      }

    default:
      return .none
    }
  }
}
