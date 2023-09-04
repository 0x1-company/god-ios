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
import StoreKit
import SwiftUI
import TcaHelpers

public struct AppLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    public init() {}

    var account = Account()

    var appDelegate = AppDelegateLogic.State()
    var sceneDelegate = SceneDelegateLogic.State()
    var view = View.State.launch()

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
    case appDelegate(AppDelegateLogic.Action)
    case sceneDelegate(SceneDelegateLogic.Action)
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
      AppDelegateLogic()
    }
    Scope(state: \.sceneDelegate, action: /Action.sceneDelegate) {
      SceneDelegateLogic()
    }
    Scope(state: \.view, action: /Action.view) {
      View()
    }
    AuthLogic()
    FirestoreLogic()
    CoreLogic()
    CurrentUserLogic()
    StoreLogic()
  }

  public struct View: Reducer {
    public enum State: Equatable {
      case launch(LaunchLogic.State = .init())
      case onboard(OnboardLogic.State = .init())
      case navigation(RootNavigationLogic.State = .init())
      case forceUpdate(ForceUpdateLogic.State = .init())
      case maintenance(MaintenanceLogic.State = .init())
    }

    public enum Action: Equatable {
      case launch(LaunchLogic.Action)
      case onboard(OnboardLogic.Action)
      case navigation(RootNavigationLogic.Action)
      case forceUpdate(ForceUpdateLogic.Action)
      case maintenance(MaintenanceLogic.Action)
    }

    public var body: some Reducer<State, Action> {
      Scope(state: /State.launch, action: /Action.launch, child: LaunchLogic.init)
      Scope(state: /State.onboard, action: /Action.onboard, child: OnboardLogic.init)
      Scope(state: /State.navigation, action: /Action.navigation, child: RootNavigationLogic.init)
      Scope(state: /State.forceUpdate, action: /Action.forceUpdate, child: ForceUpdateLogic.init)
      Scope(state: /State.maintenance, action: /Action.maintenance, child: MaintenanceLogic.init)
    }
  }
}

public struct AppView: View {
  let store: StoreOf<AppLogic>

  public init(store: StoreOf<AppLogic>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      SwitchStore(store.scope(state: \.view, action: AppLogic.Action.view)) { initialState in
        switch initialState {
        case .launch:
          CaseLet(
            /AppLogic.View.State.launch,
            action: AppLogic.View.Action.launch,
            then: LaunchView.init(store:)
          )
        case .onboard:
          CaseLet(
            /AppLogic.View.State.onboard,
            action: AppLogic.View.Action.onboard,
            then: OnboardView.init(store:)
          )
        case .navigation:
          CaseLet(
            /AppLogic.View.State.navigation,
            action: AppLogic.View.Action.navigation,
            then: RootNavigationView.init(store:)
          )
        case .forceUpdate:
          CaseLet(
            /AppLogic.View.State.forceUpdate,
            action: AppLogic.View.Action.forceUpdate,
            then: ForceUpdateView.init(store:)
          )
        case .maintenance:
          CaseLet(
            /AppLogic.View.State.maintenance,
            action: AppLogic.View.Action.maintenance,
            then: MaintenanceView.init(store:)
          )
        }
      }
      .overlay {
        if !viewStore.account.overlayHidden {
          Color.godBlack
            .ignoresSafeArea()
        }
      }
    }
  }
}
