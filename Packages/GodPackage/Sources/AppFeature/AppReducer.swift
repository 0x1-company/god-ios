import ComposableArchitecture
import Constants
import SwiftUI

public struct AppReducer: ReducerProtocol {
  public init() {}

  public struct State: Equatable {
    public init() {}

    var appDelegate = AppDelegateReducer.State()
    var sceneDelegate = SceneDelegateReducer.State()
  }

  public enum Action: Equatable {
    case appDelegate(AppDelegateReducer.Action)
    case sceneDelegate(SceneDelegateReducer.Action)

    case quickAction(String)
  }

  @Dependency(\.openURL) var openURL
  @Dependency(\.constants) var constants

  public var body: some ReducerProtocol<State, Action> {
    Scope(state: \.appDelegate, action: /Action.appDelegate) {
      AppDelegateReducer()
    }
    Scope(state: \.sceneDelegate, action: /Action.sceneDelegate) {
      SceneDelegateReducer()
    }
    Reduce { _, action in
      switch action {
      case let .appDelegate(.configurationForConnecting(.some(shortcutItem))):
        let type = shortcutItem.type
        return .run { send in
          await send(.quickAction(type))
        }

      case .appDelegate:
        return .none

      case let .sceneDelegate(.shortcutItem(shortcutItem)):
        let type = shortcutItem.type
        return .run { send in
          await send(.quickAction(type))
        }

      case .sceneDelegate:
        return .none

      case let .quickAction(key):
        let urls: [String: URL] = [
          "talk-to-founder": constants.founderURL(),
          "talk-to-developer": constants.developerURL(),
        ]

        guard let url = urls[key] else {
          return .none
        }

        return .run { _ in
          await self.openURL(url)
        }
      }
    }
  }
}

public struct AppView: View {
  let store: StoreOf<AppReducer>

  public init(store: StoreOf<AppReducer>) {
    self.store = store
  }

  public var body: some View {
    Text("AppView")
  }
}
