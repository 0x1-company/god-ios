import Build
import ComposableArchitecture
import Constants
import FirestoreClient
import ForceUpdateFeature
import MaintenanceFeature
import NavigationFeature
import SwiftUI

public struct AppReducer: Reducer {
  public init() {}

  public struct State: Equatable {
    public init() {}

    var appDelegate = AppDelegateReducer.State()
    var sceneDelegate = SceneDelegateReducer.State()
    var view = View.State.navigation()

    var quickActionURLs: [String: URL] = [
      "talk-to-founder": Constants.founderURL,
      "talk-to-developer": Constants.developerURL,
    ]
  }

  public enum Action: Equatable {
    case appDelegate(AppDelegateReducer.Action)
    case sceneDelegate(SceneDelegateReducer.Action)
    case view(View.Action)
    case quickAction(String)
    case config(TaskResult<FirestoreClient.Config>)
  }

  @Dependency(\.build) var build
  @Dependency(\.openURL) var openURL
  @Dependency(\.firestore) var firestore

  public var body: some Reducer<State, Action> {
    Scope(state: \.appDelegate, action: /Action.appDelegate) {
      AppDelegateReducer()
    }
    Scope(state: \.sceneDelegate, action: /Action.sceneDelegate) {
      SceneDelegateReducer()
    }
    Scope(state: \.view, action: /Action.view) {
      View()
    }
    Reduce { state, action in
      switch action {
      case .appDelegate(.delegate(.didFinishLaunching)):
        enum CancelID { case effect }
        return .run { send in
          for try await config in try await firestore.config() {
            await send(.config(.success(config)), animation: .default)
          }
        } catch: { error, send in
          await send(.config(.failure(error)), animation: .default)
        }
        .cancellable(id: CancelID.effect)

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

      case .view:
        return .none

      case let .quickAction(key):
        guard let url = state.quickActionURLs[key] else {
          return .none
        }
        return .run { _ in
          await openURL(url)
        }

      case let .config(.success(config)):
        let shortVersion = build.bundleShortVersion()
        if config.isForceUpdate(shortVersion) {
          state.view = .forceUpdate()
        }
        if config.isMaintenance {
          state.view = .maintenance()
        }
        return .none

      case let .config(.failure(error)):
        print(error)
        return .none
      }
    }
  }

  public struct View: Reducer {
    public enum State: Equatable {
      case navigation(RootNavigationReducer.State = .init())
      case forceUpdate(ForceUpdateReducer.State = .init())
      case maintenance(MaintenanceReducer.State = .init())
    }

    public enum Action: Equatable {
      case navigation(RootNavigationReducer.Action)
      case forceUpdate(ForceUpdateReducer.Action)
      case maintenance(MaintenanceReducer.Action)
    }

    public var body: some Reducer<State, Action> {
      Scope(state: /State.navigation, action: /Action.navigation) {
        RootNavigationReducer()
      }
      Scope(state: /State.forceUpdate, action: /Action.forceUpdate) {
        ForceUpdateReducer()
      }
      Scope(state: /State.maintenance, action: /Action.maintenance) {
        MaintenanceReducer()
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
    SwitchStore(store.scope(state: \.view, action: AppReducer.Action.view)) { initialState in
      switch initialState {
      case .navigation:
        CaseLet(
          /AppReducer.View.State.navigation,
          action: AppReducer.View.Action.navigation,
          then: RootNavigationView.init(store:)
        )
      case .forceUpdate:
        CaseLet(
          /AppReducer.View.State.forceUpdate,
          action: AppReducer.View.Action.forceUpdate,
          then: ForceUpdateView.init(store:)
        )
      case .maintenance:
        CaseLet(
          /AppReducer.View.State.maintenance,
          action: AppReducer.View.Action.maintenance,
          then: MaintenanceView.init(store:)
        )
      }
    }
  }
}
