import ComposableArchitecture
import ContactsClient
import UserDefaultsClient

public struct OnboardPathLogic: Reducer {
  @Dependency(\.userDefaults) var userDefaults
  @Dependency(\.contacts.authorizationStatus) var authorizationStatus

  var isFindFriendSkip: Bool {
    authorizationStatus(.contacts) != .notDetermined
  }

  public func reduce(
    into state: inout OnboardLogic.State,
    action: OnboardLogic.Action
  ) -> Effect<OnboardLogic.Action> {
    switch action {
    case let .pathInsert(value):
      state.path.append(value)
      return .none

    case let .path(.element(_, action)):
      switch action {
      case let .gradeSetting(.delegate(.nextScreen(generation))):
        state.generation = generation

        if generation != nil {
          state.path.append(.schoolSetting())
        } else if isFindFriendSkip {
          state.path.append(.phoneNumber())
        } else {
          state.path.append(.findFriend())
        }
        return .none

      case let .schoolSetting(.delegate(.nextScreen(schoolId))):
        state.schoolId = schoolId

        if isFindFriendSkip {
          state.path.append(.phoneNumber())
        } else {
          state.path.append(.findFriend())
        }
        return .none

      case .findFriend(.delegate(.nextScreen)):
        state.path.append(.phoneNumber())
        return .none

      case .phoneNumber(.delegate(.nextScreen)):
        state.path.append(.oneTimeCode())
        return .none

      case .oneTimeCode(.delegate(.nextScreen)):
        state.path.append(.firstNameSetting())
        return .none

      case .oneTimeCode(.delegate(.popToRoot)):
        state.path.removeAll()
        return .none

      case .firstNameSetting(.delegate(.nextScreen)):
        state.path.append(.lastNameSetting())
        return .none

      case .lastNameSetting(.delegate(.nextScreen)):
        state.path.append(.usernameSetting())
        return .none

      case .usernameSetting(.delegate(.nextScreen)):
        state.path.append(.genderSetting())
        return .none

      case .genderSetting(.delegate(.nextScreen)):
        state.path.append(.profilePhotoSetting())
        return .none

      case .profilePhotoSetting(.delegate(.nextScreen)):
        state.path.append(.addFriends())
        return .none

      case .addFriends(.delegate(.nextScreen)):
        state.path.append(.howItWorks())
        return .none

      case .howItWorks(.delegate(.start)):
        // オンボーディングすべて終わり
        return .run { _ in
          await userDefaults.setOnboardCompleted(true)
        }
      default:
        return .none
      }
    default:
      return .none
    }
  }
}
