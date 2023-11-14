import AsyncValue
import ComposableArchitecture
import FirebaseAuthClient
import FirestoreClient
import ForceUpdateFeature
import LaunchFeature
import MaintenanceFeature
import NavigationFeature
import OnboardFeature
import StoreKit
import SwiftUI
import TcaHelpers
import UserDefaultsClient

@Reducer
public struct AppLogic {
  public init() {}

  public struct State: Equatable {
    var account = Account()

    var appDelegate = AppDelegateLogic.State()
    var sceneDelegate = SceneDelegateLogic.State()
    var view: View.State

    public struct Account: Equatable {
      var authUser = AsyncValue<FirebaseAuthClient.User?>.none
      var isForceUpdate = AsyncValue<Bool>.none
      var isMaintenance = AsyncValue<Bool>.none
    }

    public init() {
      @Dependency(\.userDefaults) var userDefaults
      view = userDefaults.onboardCompleted() ? View.State.navigation() : View.State.onboard()
    }
  }

  public enum Action {
    case appDelegate(AppDelegateLogic.Action)
    case sceneDelegate(SceneDelegateLogic.Action)
    case view(View.Action)
    case configResponse(TaskResult<FirestoreClient.Config>)
    case authUserResponse(TaskResult<FirebaseAuthClient.User?>)
    case transaction(TaskResult<StoreKit.Transaction>)
    case createTransactionResponse(TaskResult<StoreKit.Transaction>)
  }

  @Dependency(\.analytics) var analytics
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
          if case .onboard = state.view {
          } else {
            state.view = .onboard()
          }
        }
        return .none
      }
      .onChange(of: \.account.authUser) { authUser, _, _ in
        if case let .success(user) = authUser {
          analytics.setUserProperty(key: .uid, value: user?.uid)
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
    Scope(state: \.appDelegate, action: \.appDelegate) {
      AppDelegateLogic()
    }
    Scope(state: \.sceneDelegate, action: \.sceneDelegate) {
      SceneDelegateLogic()
    }
    Scope(state: \.view, action: \.view) {
      View()
    }
    AuthLogic()
    StoreLogic()
    FirestoreLogic()
    QuickActionLogic()
    UserSettingsLogic()
  }

  @Reducer
  public struct View {
    public enum State: Equatable {
      case launch(LaunchLogic.State = .init())
      case onboard(OnboardLogic.State = .init())
      case navigation(RootNavigationLogic.State = .init())
      case forceUpdate(ForceUpdateLogic.State = .init())
      case maintenance(MaintenanceLogic.State = .init())
    }

    public enum Action {
      case launch(LaunchLogic.Action)
      case onboard(OnboardLogic.Action)
      case navigation(RootNavigationLogic.Action)
      case forceUpdate(ForceUpdateLogic.Action)
      case maintenance(MaintenanceLogic.Action)
    }

    public var body: some Reducer<State, Action> {
      Scope(state: \.launch, action: \.launch, child: LaunchLogic.init)
      Scope(state: \.onboard, action: \.onboard, child: OnboardLogic.init)
      Scope(state: \.navigation, action: \.navigation, child: RootNavigationLogic.init)
      Scope(state: \.forceUpdate, action: \.forceUpdate, child: ForceUpdateLogic.init)
      Scope(state: \.maintenance, action: \.maintenance, child: MaintenanceLogic.init)
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
