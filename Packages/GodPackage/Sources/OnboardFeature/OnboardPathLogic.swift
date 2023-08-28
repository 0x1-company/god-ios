import ComposableArchitecture
import ContactsClient

public struct OnboardPathLogic: Reducer {
  @Dependency(\.contacts.authorizationStatus) var authorizationStatus

  func skipFindFriend() -> Bool {
    authorizationStatus(.contacts) != .notDetermined
  }

  public func reduce(
    into state: inout OnboardReducer.State,
    action: OnboardReducer.Action
  ) -> Effect<OnboardReducer.Action> {
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
        } else if skipFindFriend() {
          state.path.append(.phoneNumber())
        } else {
          state.path.append(.findFriend())
        }
        return .none

      case let .schoolSetting(.delegate(.nextScreen(schoolId))):
        state.schoolId = schoolId

        if skipFindFriend() {
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

      case let .genderSetting(.delegate(.nextScreen(gender))):
        state.path.append(.profilePhotoSetting())
        return .send(.genderChanged(gender))

      case .profilePhotoSetting(.delegate(.nextScreen)):
        state.path.append(.addFriends())
        return .none

      case .addFriends(.delegate(.nextScreen)):
        state.path.append(.howItWorks())
        return .none

      default:
        return .none
      }
    default:
      return .none
    }
  }
}
