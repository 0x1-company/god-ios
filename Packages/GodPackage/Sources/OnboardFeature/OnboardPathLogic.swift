import AnalyticsClient
import ComposableArchitecture
import Contacts
import ContactsClient
import God
import GodClient
import InviteFriendFeature
import UIApplicationClient
import UserDefaultsClient
import UserNotificationClient

@Reducer
public struct OnboardPathLogic {
  @Dependency(\.analytics) var analytics
  @Dependency(\.godClient) var godClient
  @Dependency(\.userDefaults) var userDefaults
  @Dependency(\.contacts.enumerateContacts) var enumerateContacts
  @Dependency(\.contacts.authorizationStatus) var authorizationStatus

  var isFindFriendSkip: Bool {
    authorizationStatus(.contacts) != .notDetermined
  }

  private func contactsRequest(send: Send<Action>) async {
    do {
      let request = CNContactFetchRequest(keysToFetch: [
        CNContactGivenNameKey as CNKeyDescriptor,
        CNContactFamilyNameKey as CNKeyDescriptor,
        CNContactPhoneNumbersKey as CNKeyDescriptor,
      ])
      for try await (contact, _) in enumerateContacts(request) {
        await send(.contactResponse(.success(contact)))
      }
    } catch {
      await send(.contactResponse(.failure(error)))
    }
  }

  @Dependency(\.userNotifications.requestAuthorization) var requestAuthorization
  @Dependency(\.application.registerForRemoteNotifications) var registerForRemoteNotifications

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
          return .none

        } else if isFindFriendSkip {
          state.path.append(.invitationCode())
          return .run(priority: .background) { send in
            await contactsRequest(send: send)
          }
        }
        state.path.append(.findFriend())
        return .none

      case let .schoolSetting(.delegate(.nextScreen(schoolId))):
        state.schoolId = schoolId
        state.path.append(.clubActivitySetting())
        return .none

      case let .clubActivitySetting(.delegate(.nextScreen(clubActivityId))):
        state.clubActivityId = clubActivityId

        if isFindFriendSkip {
          state.path.append(.invitationCode())
          return .run(priority: .background) { send in
            await contactsRequest(send: send)
          }
        }
        state.path.append(.findFriend())
        return .none

      case .findFriend(.delegate(.nextScreen)):
        state.path.append(.invitationCode())
        return .run(priority: .background) { send in
          await contactsRequest(send: send)
        }

      case let .invitationCode(.delegate(.nextScreen(code))):
        state.invitationCode = code
        state.path.append(.phoneNumber())
        return .none

      case .phoneNumber(.delegate(.nextScreen)):
        state.path.append(
          .oneTimeCode(
            OneTimeCodeLogic.State(
              inviterUserId: state.inviterUserId,
              invitationCode: state.invitationCode
            )
          )
        )
        return .none

      case .oneTimeCode(.delegate(.nextScreen)):
        state.path.append(.lastNameSetting())

        analytics.setUserProperty(key: .schoolId, value: state.schoolId)
        analytics.setUserProperty(key: .generation, value: state.generation?.description)

        if state.generation == nil, state.schoolId == nil {
          return .none
        }
        let input = God.UpdateUserProfileInput(
          clubActivityId: state.clubActivityId ?? .null,
          generation: state.generation ?? .null,
          schoolId: state.schoolId ?? .null
        )
        return .run { send in
          await send(.updateUserProfileResponse(TaskResult {
            try await godClient.updateUserProfile(input)
          }))
        }

      case .oneTimeCode(.delegate(.popToRoot)):
        state.path.removeAll()
        return .none

      case .lastNameSetting(.delegate(.nextScreen)):
        state.path.append(.firstNameSetting())
        return .run { [contacts = state.contacts] send in
          let input = Array(contacts.prefix(100))
          await send(.createContactsResponse(TaskResult {
            try await godClient.createContacts(input)
          }))
        }

      case .firstNameSetting(.delegate(.nextScreen)):
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
        state.path.append(.inviteFriend())
        return .none

      case .inviteFriend(.delegate(.nextScreen)):
        return .run { _ in
          await userDefaults.setOnboardCompleted(true)
          guard try await requestAuthorization([.alert, .sound, .badge])
          else { return }
          await registerForRemoteNotifications()
        }
      default:
        return .none
      }
    default:
      return .none
    }
  }
}
