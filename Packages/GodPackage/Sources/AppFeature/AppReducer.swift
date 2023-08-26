import Build
import ComposableArchitecture
import Constants
import FirebaseAuthClient
import FirestoreClient
import ForceUpdateFeature
import MaintenanceFeature
import NavigationFeature
import OnboardFeature
import SwiftUI
import TcaHelpers
import God

public struct AppReducer: Reducer {
  public init() {}

  public struct State: Equatable {
    public init() {}

    var account = Account()

    var appDelegate = AppDelegateReducer.State()
    var sceneDelegate = SceneDelegateReducer.State()
    var view = View.State.onboard()

    var quickActionURLs: [String: URL] = [
      "talk-to-founder": Constants.founderURL,
      "talk-to-developer": Constants.developerURL,
    ]

    public struct Account: Equatable {
      var authUser: FirebaseAuthClient.User?
      var currentUser: God.CurrentUserQuery.Data.CurrentUser?
      var isForceUpdate = false
      var isMaintenance = false
    }
  }

  public enum Action: Equatable {
    case appDelegate(AppDelegateReducer.Action)
    case sceneDelegate(SceneDelegateReducer.Action)
    case view(View.Action)
    case quickAction(String)
    case configResponse(TaskResult<FirestoreClient.Config>)
    case authUserResponse(TaskResult<FirebaseAuthClient.User?>)
    case currentUserResponse(TaskResult<God.CurrentUserQuery.Data.CurrentUser>)
  }

  @Dependency(\.build) var build
  @Dependency(\.openURL) var openURL
  @Dependency(\.firestore) var firestore
  @Dependency(\.firebaseAuth) var firebaseAuth

  public var body: some Reducer<State, Action> {
    core
      .onChange(of: \.account) { account, state, _ in
        if account.isForceUpdate {
          state.view = .forceUpdate()
          return .none
        }
        if account.isMaintenance {
          state.view = .maintenance()
          return .none
        }
        if account.authUser == nil {
          state.view = .onboard()
          return .none
        }
        /// UserDefaultsにあるオンボーディング突破フラグがONだとnavigationにする
//        state.view = .navigation()
        return .none
      }
  }

  @ReducerBuilder<State, Action>
  var core: some Reducer<State, Action> {
    Scope(state: \.appDelegate, action: /Action.appDelegate) {
      AppDelegateReducer()
    }
    Scope(state: \.sceneDelegate, action: /Action.sceneDelegate) {
      SceneDelegateReducer()
    }
    Scope(state: \.view, action: /Action.view) {
      View()
    }
    AuthLogic()
    FirestoreLogic()
    CoreLogic()
    CurrentUserLogic()
  }

  public struct View: Reducer {
    public enum State: Equatable {
      case onboard(OnboardReducer.State = .init())
      case navigation(RootNavigationReducer.State = .init())
      case forceUpdate(ForceUpdateReducer.State = .init())
      case maintenance(MaintenanceReducer.State = .init())
    }

    public enum Action: Equatable {
      case onboard(OnboardReducer.Action)
      case navigation(RootNavigationReducer.Action)
      case forceUpdate(ForceUpdateReducer.Action)
      case maintenance(MaintenanceReducer.Action)
    }

    public var body: some Reducer<State, Action> {
      Scope(state: /State.onboard, action: /Action.onboard, child: OnboardReducer.init)
      Scope(state: /State.navigation, action: /Action.navigation, child: RootNavigationReducer.init)
      Scope(state: /State.forceUpdate, action: /Action.forceUpdate, child: ForceUpdateReducer.init)
      Scope(state: /State.maintenance, action: /Action.maintenance, child: MaintenanceReducer.init)
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
      case .onboard:
        CaseLet(
          /AppReducer.View.State.onboard,
          action: AppReducer.View.Action.onboard,
          then: OnboardView.init(store:)
        )
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
