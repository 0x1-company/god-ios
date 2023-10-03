import ComposableArchitecture
import Contacts
import ContactsClient
import FirebaseAuth
import FirebaseDynamicLinkClient
import FirebaseDynamicLinks
import God
import HowItWorksFeature
import SwiftUI

public struct OnboardLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    var welcome = WelcomeLogic.State()
    var path = StackState<Path.State>()
    var generation: Int?
    var schoolId: String?
    var inviterUserId: String?
    var contacts: [God.ContactInput] = []

    public init() {}
  }

  public enum Action: Equatable {
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

  @Dependency(\.firebaseDynamicLinks) var firebaseDynamicLinks

  public var body: some Reducer<State, Action> {
    OnboardPathLogic()
    OnboardContactLogic()
    Scope(state: \.welcome, action: /Action.welcome) {
      WelcomeLogic()
    }
    Reduce<State, Action> { state, action in
      switch action {
      case .welcome(.getStartedButtonTapped):
        state.path.append(.gradeSetting())
        return .none

      case .welcome(.loginButtonTapped):
        state.path.append(.gradeSetting())
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
    .forEach(\.path, action: /Action.path) {
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

  public struct Path: Reducer {
    public enum State: Equatable {
      case gradeSetting(GradeSettingLogic.State = .init())
      case schoolSetting(SchoolSettingLogic.State = .init())
      case findFriend(FindFriendLogic.State = .init())
      case phoneNumber(PhoneNumberLogic.State = .init())
      case oneTimeCode(OneTimeCodeLogic.State)
      case firstNameSetting(FirstNameSettingLogic.State = .init())
      case lastNameSetting(LastNameSettingLogic.State = .init())
      case usernameSetting(UsernameSettingLogic.State = .init())
      case genderSetting(GenderSettingLogic.State = .init())
      case profilePhotoSetting(ProfilePhotoSettingLogic.State = .init())
      case addFriends(AddFriendsLogic.State)
      case howItWorks(HowItWorksLogic.State = .init())
    }

    public enum Action: Equatable {
      case gradeSetting(GradeSettingLogic.Action)
      case schoolSetting(SchoolSettingLogic.Action)
      case findFriend(FindFriendLogic.Action)
      case phoneNumber(PhoneNumberLogic.Action)
      case oneTimeCode(OneTimeCodeLogic.Action)
      case firstNameSetting(FirstNameSettingLogic.Action)
      case lastNameSetting(LastNameSettingLogic.Action)
      case usernameSetting(UsernameSettingLogic.Action)
      case genderSetting(GenderSettingLogic.Action)
      case profilePhotoSetting(ProfilePhotoSettingLogic.Action)
      case addFriends(AddFriendsLogic.Action)
      case howItWorks(HowItWorksLogic.Action)
    }

    public var body: some Reducer<State, Action> {
      Scope(state: /State.gradeSetting, action: /Action.gradeSetting, child: GradeSettingLogic.init)
      Scope(state: /State.schoolSetting, action: /Action.schoolSetting, child: SchoolSettingLogic.init)
      Scope(state: /State.findFriend, action: /Action.findFriend, child: FindFriendLogic.init)
      Scope(state: /State.phoneNumber, action: /Action.phoneNumber, child: PhoneNumberLogic.init)
      Scope(state: /State.oneTimeCode, action: /Action.oneTimeCode, child: OneTimeCodeLogic.init)
      Scope(state: /State.firstNameSetting, action: /Action.firstNameSetting, child: FirstNameSettingLogic.init)
      Scope(state: /State.lastNameSetting, action: /Action.lastNameSetting, child: LastNameSettingLogic.init)
      Scope(state: /State.usernameSetting, action: /Action.usernameSetting, child: UsernameSettingLogic.init)
      Scope(state: /State.genderSetting, action: /Action.genderSetting, child: GenderSettingLogic.init)
      Scope(state: /State.profilePhotoSetting, action: /Action.profilePhotoSetting, child: ProfilePhotoSettingLogic.init)
      Scope(state: /State.addFriends, action: /Action.addFriends, child: AddFriendsLogic.init)
      Scope(state: /State.howItWorks, action: /Action.howItWorks, child: HowItWorksLogic.init)
    }
  }
}

public struct OnboardView: View {
  let store: StoreOf<OnboardLogic>

  public init(store: StoreOf<OnboardLogic>) {
    self.store = store
  }

  public var body: some View {
    NavigationStackStore(store.scope(state: \.path, action: { .path($0) })) {
      WelcomeView(store: store.scope(state: \.welcome, action: OnboardLogic.Action.welcome))
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
      case .findFriend:
        CaseLet(
          /OnboardLogic.Path.State.findFriend,
          action: OnboardLogic.Path.Action.findFriend,
          then: FindFriendView.init(store:)
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
      case .howItWorks:
        CaseLet(
          /OnboardLogic.Path.State.howItWorks,
          action: OnboardLogic.Path.Action.howItWorks,
          then: HowItWorksView.init(store:)
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
