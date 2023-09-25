import ComposableArchitecture
import Constants

public struct QuickActionLogic: Reducer {
  @Dependency(\.openURL) var openURL

  public func reduce(
    into state: inout AppLogic.State,
    action: AppLogic.Action
  ) -> Effect<AppLogic.Action> {
    switch action {
    case let .appDelegate(.configurationForConnecting(.some(shortcutItem))):
      let type = shortcutItem.type
      return .run { send in
        await quickAction(send: send, type: type)
      }

    case let .sceneDelegate(.shortcutItem(shortcutItem)):
      let type = shortcutItem.type
      return .run { send in
        await quickAction(send: send, type: type)
      }

    default:
      return .none
    }
  }

  private func quickAction(send: Send<Action>, type: String) async {
    guard let url = Constants.quickActionURLs[type] else { return }
    await openURL(url)
  }
}
