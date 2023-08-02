import ComposableArchitecture
import Constants
import NavigationFeature
import SwiftUI

public struct AppReducer: Reducer {
  public init() {}

  public struct State: Equatable {
    public init() {}

    var appDelegate = AppDelegateReducer.State()
    var sceneDelegate = SceneDelegateReducer.State()
    var navigation = RootNavigationReducer.State()
  }

  public enum Action: Equatable {
    case appDelegate(AppDelegateReducer.Action)
    case sceneDelegate(SceneDelegateReducer.Action)
    case navigation(RootNavigationReducer.Action)

    case quickAction(String)
  }

  @Dependency(\.openURL) var openURL

  public var body: some Reducer<State, Action> {
    Scope(state: \.appDelegate, action: /Action.appDelegate) {
      AppDelegateReducer()
    }
    Scope(state: \.sceneDelegate, action: /Action.sceneDelegate) {
      SceneDelegateReducer()
    }
    Scope(state: \.navigation, action: /Action.navigation) {
      RootNavigationReducer()
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

      case .navigation:
        return .none

      case let .quickAction(key):
        let urls: [String: URL] = [
          "talk-to-founder": Constants.founderURL,
          "talk-to-developer": Constants.developerURL,
        ]

        guard let url = urls[key] else {
          return .none
        }

        return .run { _ in
          await openURL(url)
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
    RootNavigationView(
      store: store.scope(
        state: \.navigation,
        action: AppReducer.Action.navigation
      )
    )
  }
}
