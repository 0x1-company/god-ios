import ComposableArchitecture
import GenderSettingFeature
import SwiftUI

public struct OnboardReducer: Reducer {
  public init() {}

  public struct State: Equatable {
    var welcome = WelcomeReducer.State()
    var path = StackState<Path.State>()
    public init() {}
  }

  public enum Action: Equatable {
    case welcome(WelcomeReducer.Action)
    case path(StackAction<Path.State, Path.Action>)
  }

  public var body: some ReducerOf<Self> {
    Scope(state: \.welcome, action: /Action.welcome) {
      WelcomeReducer()
    }
    Reduce { state, action in
      switch action {
      case .welcome(.getStartedButtonTapped):
        state.path.append(.firstNameSetting())
        return .none

      case .welcome:
        return .none

      case .path(.element(_, .firstNameSetting(.delegate(.nextLastNameSetting)))):
        state.path.append(.lastNameSetting())
        return .none

      case .path(.element(_, .lastNameSetting(.delegate(.nextUsernameSetting)))):
        state.path.append(.usernameSetting())
        return .none

      case .path(.element(_, .usernameSetting(.delegate(.nextGenderSetting)))):
        state.path.append(.genderSetting())
        return .none
        
      case .path(.element(_, .genderSetting(.delegate(.nextProfilePhotoSetting)))):
        state.path.append(.profilePhotoSetting())
        return .none

      case .path:
        return .none
      }
    }
    .forEach(\.path, action: /Action.path) {
      Path()
    }
  }

  public struct Path: Reducer {
    public enum State: Equatable {
      case firstNameSetting(FirstNameSettingReducer.State = .init())
      case lastNameSetting(LastNameSettingReducer.State = .init())
      case usernameSetting(UsernameSettingReducer.State = .init())
      case genderSetting(GenderSettingReducer.State = .init())
      case profilePhotoSetting(ProfilePhotoSettingReducer.State = .init())
    }

    public enum Action: Equatable {
      case firstNameSetting(FirstNameSettingReducer.Action)
      case lastNameSetting(LastNameSettingReducer.Action)
      case usernameSetting(UsernameSettingReducer.Action)
      case genderSetting(GenderSettingReducer.Action)
      case profilePhotoSetting(ProfilePhotoSettingReducer.Action)
    }

    public var body: some ReducerOf<Self> {
      Scope(state: /State.firstNameSetting, action: /Action.firstNameSetting) {
        FirstNameSettingReducer()
      }
      Scope(state: /State.lastNameSetting, action: /Action.lastNameSetting) {
        LastNameSettingReducer()
      }
      Scope(state: /State.usernameSetting, action: /Action.usernameSetting) {
        UsernameSettingReducer()
      }
      Scope(state: /State.genderSetting, action: /Action.genderSetting) {
        GenderSettingReducer()
      }
      Scope(state: /State.profilePhotoSetting, action: /Action.profilePhotoSetting) {
        ProfilePhotoSettingReducer()
      }
    }
  }
}

public struct OnboardView: View {
  let store: StoreOf<OnboardReducer>

  public init(store: StoreOf<OnboardReducer>) {
    self.store = store
  }

  public var body: some View {
    NavigationStackStore(store.scope(state: \.path, action: { .path($0) })) {
      WelcomeView(store: store.scope(state: \.welcome, action: OnboardReducer.Action.welcome))
    } destination: { store in
      switch store {
      case .firstNameSetting:
        CaseLet(
          /OnboardReducer.Path.State.firstNameSetting,
          action: OnboardReducer.Path.Action.firstNameSetting,
          then: FirstNameSettingView.init(store:)
        )
      case .lastNameSetting:
        CaseLet(
          /OnboardReducer.Path.State.lastNameSetting,
          action: OnboardReducer.Path.Action.lastNameSetting,
          then: LastNameSettingView.init(store:)
        )
      case .usernameSetting:
        CaseLet(
          /OnboardReducer.Path.State.usernameSetting,
          action: OnboardReducer.Path.Action.usernameSetting,
          then: UsernameSettingView.init(store:)
        )
      case .genderSetting:
        CaseLet(
          /OnboardReducer.Path.State.genderSetting,
          action: OnboardReducer.Path.Action.genderSetting,
          then: GenderSettingView.init(store:)
        )
      case .profilePhotoSetting:
        CaseLet(
          /OnboardReducer.Path.State.profilePhotoSetting,
          action: OnboardReducer.Path.Action.profilePhotoSetting,
          then: ProfilePhotoSettingView.init(store:)
        )
      }
    }
    .tint(Color.white)
  }
}
