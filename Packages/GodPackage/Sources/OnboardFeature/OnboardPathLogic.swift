import ComposableArchitecture
import ContactsClient

public struct OnboardPathLogic: Reducer {
  @Dependency(\.contacts.authorizationStatus) var authorizationStatus
  
  func skipFindFriend() -> Bool {
    return .notDetermined != authorizationStatus(.contacts)
  }
  
  public func reduce(
    into state: inout OnboardReducer.State,
    action: OnboardReducer.Action
  ) -> Effect<OnboardReducer.Action> {
    switch action {
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
        
      case let .phoneNumber(.delegate(.numberChanged(number))):
        state.phoneNumber = number
        return .none
        
      case let .phoneNumber(.delegate(.nextScreen(verifyID))):
        state.path.append(.oneTimeCode(.init(verifyID: verifyID)))
        return .none
        
      case .oneTimeCode(.delegate(.nextScreen)):
        state.path.append(.firstNameSetting())
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
        return .run { send in
          await send(.genderChanged(gender))
        }

      case .profilePhotoSetting(.delegate(.nextScreen)):
        state.path.append(.addFriends())
        return .none
        
      case .addFriends(.delegate(.nextScreen)):
        state.path.append(.howItWorks())
        return .none

      default:
        print(action)
        return .none
      }
    default:
      return .none
    }
  }
}
