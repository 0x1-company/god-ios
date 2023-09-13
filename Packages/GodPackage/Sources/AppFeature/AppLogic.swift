import AsyncValue
import ComposableArchitecture
import FirebaseAuthClient
import FirestoreClient
import ForceUpdateFeature
import LaunchFeature
import MaintenanceFeature
import NavigationFeature
import OnboardFeature
import SwiftUI
import TcaHelpers
import UserDefaultsClient

public struct AppLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    public init() {}

    var account = Account()

    var appDelegate = AppDelegateLogic.State()
    var sceneDelegate = SceneDelegateLogic.State()
    var view = View.State.onboard()

    public struct Account: Equatable {
      var authUser = AsyncValue<FirebaseAuthClient.User?>.none
      var isForceUpdate = AsyncValue<Bool>.none
      var isMaintenance = AsyncValue<Bool>.none
    }
  }

  public enum Action: Equatable {
    case appDelegate(AppDelegateLogic.Action)
    case sceneDelegate(SceneDelegateLogic.Action)
    case view(View.Action)
    case quickAction(String)
    case configResponse(TaskResult<FirestoreClient.Config>)
    case authUserResponse(TaskResult<FirebaseAuthClient.User?>)
  }

  @Dependency(\.mainQueue) var mainQueue
  @Dependency(\.userDefaults) var userDefaults

  public var body: some Reducer<State, Action> {
    core
      .onChange(of: \.account.isForceUpdate) { isForceUpdate, state, _ in
        if case .success(true) = isForceUpdate {
          state.view = .forceUpdate()
        }
        return .none
      }
      .onChange(of: \.account.isMaintenance) { isMaintenance, state, _ in
        if case .success(true) = isMaintenance {
          state.view = .maintenance()
        }
        return .none
      }
      .onChange(of: \.account) { account, state, _ in
        guard
          case .success(false) = account.isForceUpdate,
          case .success(false) = account.isMaintenance,
          case let .success(user) = account.authUser
        else { return .none }
        let onboardCompleted = userDefaults.onboardCompleted()
        if user != nil, onboardCompleted {
          state.view = .navigation()
        } else {
          state.view = .onboard()
        }
        return .none
      }
    Reduce<State, Action> { state, action in
      switch action {
      case .view(.onboard(.path(.element(_, .howItWorks(.delegate(.start)))))):
        state.view = .navigation()
        return .none
      default:
        return .none
      }
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
    StoreLogic()
    QuickActionLogic()
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
  }
}
