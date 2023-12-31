import ComposableArchitecture
import Contacts
import ContactsClient
import FindFriendFeature
import FirebaseAuth
import FirebaseDynamicLinkClient
import FirebaseDynamicLinks
import God
import InviteFriendFeature
import SchoolSettingFeature
import SwiftUI
import UserDefaultsClient

@Reducer
public struct OnboardLogic {
  public init() {}

  public struct State: Equatable {
    var welcome = WelcomeLogic.State()
    var path = StackState<Path.State>()
    var generation: Int?
    var schoolId: String?
    var clubActivityId: String?
    var inviterUserId: String?
    var invitationCode: String?
    var contacts: [God.ContactInput] = []

    public init() {}
  }

  public enum Action {
    case onTask
    case onOpenURL(URL)
    case welcome(WelcomeLogic.Action)
    case path(StackAction<Path.State, Path.Action>)
    case pathInsert(Path.State)
    case contactResponse(TaskResult<CNContact>)
    case updateUserProfileResponse(TaskResult<God.UpdateUserProfileMutation.Data>)
    case createContactsResponse(TaskResult<God.CreateContactsMutation.Data>)
    case dynamicLinkResponse(TaskResult<DynamicLink>)

    public enum Alert: Equatable {
      case confirmOkay
    }
  }

  @Dependency(\.userDefaults) var userDefaults
  @Dependency(\.firebaseDynamicLinks) var firebaseDynamicLinks

  public var body: some Reducer<State, Action> {
    OnboardPathLogic()
    OnboardContactLogic()
    Scope(state: \.welcome, action: \.welcome) {
      WelcomeLogic()
    }
    Reduce<State, Action> { state, action in
      switch action {
      case .welcome(.getStartedButtonTapped):
        state.path.append(.gradeSetting())
        guard
          let deepLink = userDefaults.dynamicLinkURL(),
          let inviterUserId = getInviterUserId(from: deepLink)
        else { return .none }
        state.inviterUserId = inviterUserId
        return .none

      case .welcome(.loginButtonTapped):
        state.path.append(.gradeSetting())
        guard
          let deepLink = userDefaults.dynamicLinkURL(),
          let inviterUserId = getInviterUserId(from: deepLink)
        else { return .none }
        state.inviterUserId = inviterUserId
        return .none

      case let .onOpenURL(url):
        return .run { send in
          await send(.dynamicLinkResponse(TaskResult {
            try await firebaseDynamicLinks.dynamicLink(url)
          }))
        }

      case let .dynamicLinkResponse(.success(dynamicLink)):
        guard
          let deepLink = dynamicLink.url,
          let inviterUserId = getInviterUserId(from: deepLink.absoluteString)
        else { return .none }
        state.inviterUserId = inviterUserId
        return .none

      default:
        return .none
      }
    }
    .forEach(\.path, action: \.path) {
      Path()
    }
  }

  func getInviterUserId(from urlString: String) -> String? {
    // 正規表現パターン
    let pattern = #"https://godapp.jp/users/([0-9a-fA-F\-]+)"#

    // 正規表現マッチング
    if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
      if let match = regex.firstMatch(in: urlString, options: [], range: NSRange(location: 0, length: urlString.utf16.count)) {
        let uuidRange = Range(match.range(at: 1), in: urlString)
        if let uuidRange {
          let uuid = urlString[uuidRange]
          return String(uuid)
        }
      }
    }
    return nil
  }

  @Reducer
  public struct Path {
    public enum State: Equatable {
      case gradeSetting(GradeSettingLogic.State = .init())
      case schoolSetting(SchoolSettingLogic.State = .init())
      case clubActivitySetting(ClubActivitySettingLogic.State = .init())
      case findFriend(FindFriendLogic.State = .init())
      case invitationCode(InvitationCodeLogic.State = .init())
      case phoneNumber(PhoneNumberLogic.State = .init())
      case oneTimeCode(OneTimeCodeLogic.State)
      case firstNameSetting(FirstNameSettingLogic.State = .init())
      case lastNameSetting(LastNameSettingLogic.State = .init())
      case usernameSetting(UsernameSettingLogic.State = .init())
      case genderSetting(GenderSettingLogic.State = .init())
      case profilePhotoSetting(ProfilePhotoSettingLogic.State = .init())
      case addFriends(AddFriendsLogic.State = .init())
      case inviteFriend(InviteFriendLogic.State = .init())
    }

    public enum Action {
      case gradeSetting(GradeSettingLogic.Action)
      case schoolSetting(SchoolSettingLogic.Action)
      case clubActivitySetting(ClubActivitySettingLogic.Action)
      case findFriend(FindFriendLogic.Action)
      case invitationCode(InvitationCodeLogic.Action)
      case phoneNumber(PhoneNumberLogic.Action)
      case oneTimeCode(OneTimeCodeLogic.Action)
      case firstNameSetting(FirstNameSettingLogic.Action)
      case lastNameSetting(LastNameSettingLogic.Action)
      case usernameSetting(UsernameSettingLogic.Action)
      case genderSetting(GenderSettingLogic.Action)
      case profilePhotoSetting(ProfilePhotoSettingLogic.Action)
      case addFriends(AddFriendsLogic.Action)
      case inviteFriend(InviteFriendLogic.Action)
    }

    public var body: some Reducer<State, Action> {
      Scope(state: \.gradeSetting, action: \.gradeSetting, child: GradeSettingLogic.init)
      Scope(state: \.schoolSetting, action: \.schoolSetting, child: SchoolSettingLogic.init)
      Scope(state: \.clubActivitySetting, action: \.clubActivitySetting, child: ClubActivitySettingLogic.init)
      Scope(state: \.findFriend, action: \.findFriend, child: FindFriendLogic.init)
      Scope(state: \.invitationCode, action: \.invitationCode, child: InvitationCodeLogic.init)
      Scope(state: \.phoneNumber, action: \.phoneNumber, child: PhoneNumberLogic.init)
      Scope(state: \.oneTimeCode, action: \.oneTimeCode, child: OneTimeCodeLogic.init)
      Scope(state: \.firstNameSetting, action: \.firstNameSetting, child: FirstNameSettingLogic.init)
      Scope(state: \.lastNameSetting, action: \.lastNameSetting, child: LastNameSettingLogic.init)
      Scope(state: \.usernameSetting, action: \.usernameSetting, child: UsernameSettingLogic.init)
      Scope(state: \.genderSetting, action: \.genderSetting, child: GenderSettingLogic.init)
      Scope(state: \.profilePhotoSetting, action: \.profilePhotoSetting, child: ProfilePhotoSettingLogic.init)
      Scope(state: \.addFriends, action: \.addFriends, child: AddFriendsLogic.init)
      Scope(state: \.inviteFriend, action: \.inviteFriend, child: InviteFriendLogic.init)
    }
  }
}

public struct OnboardView: View {
  let store: StoreOf<OnboardLogic>

  public init(store: StoreOf<OnboardLogic>) {
    self.store = store
  }

  public var body: some View {
    NavigationStackStore(store.scope(state: \.path, action: \.path)) {
      WelcomeView(store: store.scope(state: \.welcome, action: \.welcome))
    } destination: { store in
      switch store {
      case .gradeSetting:
        CaseLet(
          /OnboardLogic.Path.State.gradeSetting,
          action: OnboardLogic.Path.Action.gradeSetting,
          then: GradeSettingView.init(store:)
        )
      case .schoolSetting:
        CaseLet(
          /OnboardLogic.Path.State.schoolSetting,
          action: OnboardLogic.Path.Action.schoolSetting,
          then: SchoolSettingView.init(store:)
        )
      case .clubActivitySetting:
        CaseLet(
          /OnboardLogic.Path.State.clubActivitySetting,
          action: OnboardLogic.Path.Action.clubActivitySetting,
          then: ClubActivitySettingView.init(store:)
        )
      case .findFriend:
        CaseLet(
          /OnboardLogic.Path.State.findFriend,
          action: OnboardLogic.Path.Action.findFriend,
          then: FindFriendView.init(store:)
        )
      case .invitationCode:
        CaseLet(
          /OnboardLogic.Path.State.invitationCode,
          action: OnboardLogic.Path.Action.invitationCode,
          then: InvitationCodeView.init(store:)
        )
      case .phoneNumber:
        CaseLet(
          /OnboardLogic.Path.State.phoneNumber,
          action: OnboardLogic.Path.Action.phoneNumber,
          then: PhoneNumberView.init(store:)
        )
      case .oneTimeCode:
        CaseLet(
          /OnboardLogic.Path.State.oneTimeCode,
          action: OnboardLogic.Path.Action.oneTimeCode,
          then: OneTimeCodeView.init(store:)
        )
      case .firstNameSetting:
        CaseLet(
          /OnboardLogic.Path.State.firstNameSetting,
          action: OnboardLogic.Path.Action.firstNameSetting,
          then: FirstNameSettingView.init(store:)
        )
      case .lastNameSetting:
        CaseLet(
          /OnboardLogic.Path.State.lastNameSetting,
          action: OnboardLogic.Path.Action.lastNameSetting,
          then: LastNameSettingView.init(store:)
        )
      case .usernameSetting:
        CaseLet(
          /OnboardLogic.Path.State.usernameSetting,
          action: OnboardLogic.Path.Action.usernameSetting,
          then: UsernameSettingView.init(store:)
        )
      case .genderSetting:
        CaseLet(
          /OnboardLogic.Path.State.genderSetting,
          action: OnboardLogic.Path.Action.genderSetting,
          then: GenderSettingView.init(store:)
        )
      case .profilePhotoSetting:
        CaseLet(
          /OnboardLogic.Path.State.profilePhotoSetting,
          action: OnboardLogic.Path.Action.profilePhotoSetting,
          then: ProfilePhotoSettingView.init(store:)
        )
      case .addFriends:
        CaseLet(
          /OnboardLogic.Path.State.addFriends,
          action: OnboardLogic.Path.Action.addFriends,
          then: AddFriendsView.init(store:)
        )
      case .inviteFriend:
        CaseLet(
          /OnboardLogic.Path.State.inviteFriend,
          action: OnboardLogic.Path.Action.inviteFriend,
          then: InviteFriendView.init(store:)
        )
      }
    }
    .tint(Color.white)
    .task { await store.send(.onTask).finish() }
    .onOpenURL { url in
      store.send(.onOpenURL(url))
    }
  }
}
