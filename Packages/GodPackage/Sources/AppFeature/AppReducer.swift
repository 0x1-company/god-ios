import ComposableArchitecture
import Constants
import FirebaseAuthClient
import FirestoreClient
import ForceUpdateFeature
import God
import LaunchFeature
import MaintenanceFeature
import NavigationFeature
import OnboardFeature
import SwiftUI
import TcaHelpers
import StoreKit

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
      var onboardCongrats = false
      var overlayHidden = false
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
    case overlayHidden
  }

  @Dependency(\.mainQueue) var mainQueue

  public var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .view(.onboard(.path(.element(_, .howItWorks(.delegate(.start)))))):
        state.account.onboardCongrats = true
        return .none

      case .appDelegate(.delegate(.didFinishLaunching)):
        return .run { send in
          try await mainQueue.sleep(for: .seconds(3))
          await send(.overlayHidden, animation: .default)
        }

      case .overlayHidden:
        state.account.overlayHidden = true
        return .none

      default:
        return .none
      }
    }
    core
      .onChange(of: \.account) { account, state, _ in
        print(".onChange(of:): \(account)")
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
        guard let currentUser = account.currentUser else {
          state.view = .onboard()
          return .none
        }
        if account.onboardCongrats {
          state.view = .navigation()
          return .none
        }
        if currentUser.firstName.isEmpty || currentUser.lastName.isEmpty || currentUser.username == nil {
          state.view = .onboard()
          return .none
        }
        state.view = .navigation()
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
      case launch(LaunchReducer.State = .init())
      case onboard(OnboardReducer.State = .init())
      case navigation(RootNavigationReducer.State = .init())
      case forceUpdate(ForceUpdateReducer.State = .init())
      case maintenance(MaintenanceReducer.State = .init())
    }

    public enum Action: Equatable {
      case launch(LaunchReducer.Action)
      case onboard(OnboardReducer.Action)
      case navigation(RootNavigationReducer.Action)
      case forceUpdate(ForceUpdateReducer.Action)
      case maintenance(MaintenanceReducer.Action)
    }

    public var body: some Reducer<State, Action> {
      Scope(state: /State.launch, action: /Action.launch, child: LaunchReducer.init)
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
    WithViewStore(store, observe: { $0 }) { viewStore in
      SwitchStore(store.scope(state: \.view, action: AppReducer.Action.view)) { initialState in
        switch initialState {
        case .launch:
          CaseLet(
            /AppReducer.View.State.launch,
            action: AppReducer.View.Action.launch,
            then: LaunchView.init(store:)
          )
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
      .overlay {
        if !viewStore.account.overlayHidden {
          Color.black
            .ignoresSafeArea()
        }
      }
    }
  }
}
