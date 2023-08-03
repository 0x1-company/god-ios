import ComposableArchitecture
import SwiftUI

public struct OnboardReducer: Reducer {
  public init() {}

  public struct State: Equatable {
    var path = StackState<Path.State>()
    public init() {}
  }

  public enum Action: Equatable {
    case path(StackAction<Path.State, Path.Action>)
  }

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .path:
        return .none
      }
    }
    .forEach(\.path, action: /Action.path) {
      Path()
    }
  }
}

extension OnboardReducer {
  public struct Path: Reducer {
    public enum State: Equatable {
      case welcome(WelcomeReducer.State = .init())
      case firstNameSetting(FirstNameSettingReducer.State = .init())
      case lastNameSetting(LastNameSettingReducer.State = .init())
      case usernameSetting(UsernameSettingReducer.State = .init())
      case genderSetting(GenderSettingReducer.State = .init())
      case avatarSetting(AvatarSettingReducer.State = .init())
    }

    public enum Action: Equatable {
      case welcome(WelcomeReducer.Action)
      case firstNameSetting(FirstNameSettingReducer.Action)
      case lastNameSetting(LastNameSettingReducer.Action)
      case usernameSetting(UsernameSettingReducer.Action)
      case genderSetting(GenderSettingReducer.Action)
      case avatarSetting(AvatarSettingReducer.Action)
    }

    public var body: some ReducerOf<Self> {
      Scope(state: /State.welcome, action: /Action.welcome) {
        WelcomeReducer()
      }
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
      Scope(state: /State.avatarSetting, action: /Action.avatarSetting) {
        AvatarSettingReducer()
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
    WithViewStore(store, observe: { $0 }) { viewStore in
      List {
        Text("Onboard")
      }
      .navigationTitle("Onboard")
      .navigationBarTitleDisplayMode(.inline)
    }
  }
}
