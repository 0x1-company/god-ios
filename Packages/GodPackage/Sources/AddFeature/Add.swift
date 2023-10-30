import AnalyticsClient
import ComposableArchitecture
import Constants
import Contacts
import ContactsClient
import CupertinoMessageFeature
import God
import GodClient
import ProfileFeature
import ProfileStoryFeature
import SearchField
import ShareLinkBuilder
import SocialShare
import Styleguide
import SwiftUI
import UIApplicationClient
import UIPasteboardClient

public struct AddLogic: Reducer {
  public init() {}
  public struct Destination: Reducer {
    public enum State: Equatable {
      case profileExternal(ProfileExternalLogic.State)
      case message(CupertinoMessageLogic.State)
    }

    public enum Action: Equatable {
      case profileExternal(ProfileExternalLogic.Action)
      case message(CupertinoMessageLogic.Action)
    }

    public var body: some Reducer<State, Action> {
      Scope(state: /State.profileExternal, action: /Action.profileExternal, child: ProfileExternalLogic.init)
      Scope(state: /State.message, action: /Action.message, child: CupertinoMessageLogic.init)
    }
  }

  public struct State: Equatable {
    var shareURL = URL(string: "https://godapp.jp")!
    @BindingState var searchQuery = ""
    @PresentationState var destination: Destination.State?

    var contactsReEnable: ContactsReEnableLogic.State?
    var invitationsLeft = InvitationsLeftLogic.State()
    var friendRequestPanel: FriendRequestsLogic.State?
    var friendsOfFriendsPanel: FriendsOfFriendsPanelLogic.State?
    var fromSchoolPanel: FromSchoolPanelLogic.State?

    var profileImageData: Data?
    var schoolImageData: Data?
    var currentUser: God.AddPlusQuery.Data.CurrentUser?
    var searchResult: IdentifiedArrayOf<FriendRowCardLogic.State> = []
    public init() {}
  }

  public enum Action: Equatable, BindableAction {
    case onTask
    case onAppear
    case storyButtonTapped(UIImage?)
    case lineButtonTapped
    case messageButtonTapped
    case searchResponse(TaskResult<God.UserSearchQuery.Data>)
    case addPlusResponse(TaskResult<God.AddPlusQuery.Data>)
    case profileImageResponse(TaskResult<Data>)
    case schoolImageResponse(TaskResult<Data>)
    case binding(BindingAction<State>)
    case contactsReEnable(ContactsReEnableLogic.Action)
    case invitationsLeft(InvitationsLeftLogic.Action)
    case friendRequestPanel(FriendRequestsLogic.Action)
    case friendsOfFriendsPanel(FriendsOfFriendsPanelLogic.Action)
    case fromSchoolPanel(FromSchoolPanelLogic.Action)
    case searchResult(id: FriendRowCardLogic.State.ID, action: FriendRowCardLogic.Action)
    case destination(PresentationAction<Destination.Action>)
  }

  @Dependency(\.openURL) var openURL
  @Dependency(\.mainQueue) var mainQueue
  @Dependency(\.godClient) var godClient
  @Dependency(\.analytics) var analytics
  @Dependency(\.pasteboard) var pasteboard
  @Dependency(\.urlSession) var urlSession
  @Dependency(\.contacts.authorizationStatus) var contactsAuthorizationStatus

  enum Cancel {
    case search
  }

  public var body: some Reducer<State, Action> {
    BindingReducer()
    Scope(state: \.invitationsLeft, action: /Action.invitationsLeft) {
      InvitationsLeftLogic()
    }
    Reduce<State, Action> { state, _ in
      state.contactsReEnable = contactsAuthorizationStatus(.contacts) != .authorized ? .init() : nil
      return .none
    }
    Reduce<State, Action> { state, action in
      switch action {
      case .onTask:
        return .run { send in
          await addPlusRequest(send: send)
        }
      case .onAppear:
        analytics.logScreen(screenName: "AddPlus", of: self)

        return .none
      case let .storyButtonTapped(.some(profileCardImage)):
        analytics.buttonClick(name: .storyShare)
        guard let imageData = profileCardImage.pngData() else {
          return .none
        }
        let pasteboardItems: [String: Any] = [
          "com.instagram.sharedSticker.stickerImage": imageData,
          "com.instagram.sharedSticker.backgroundTopColor": "#000000",
          "com.instagram.sharedSticker.backgroundBottomColor": "#000000",
        ]
        pasteboard.setItems(
          [pasteboardItems],
          [.expirationDate: Date().addingTimeInterval(300)]
        )
        return .run { _ in
          await openURL(Constants.storiesURL)
        }

      case .lineButtonTapped:
        analytics.buttonClick(name: .lineShare)
        guard let lineURL = ShareLinkBuilder.buildForLine(
          path: .add,
          username: state.currentUser?.username
        ) else { return .none }
        return .run { _ in
          await openURL(lineURL)
        }

      case .messageButtonTapped:
        analytics.buttonClick(name: .smsShare)
        guard let smsText = ShareLinkBuilder.buildShareText(
          path: .invite,
          username: state.currentUser?.username,
          source: .sms,
          medium: .add
        ) else { return .none }
        state.destination = .message(
          CupertinoMessageLogic.State(recipients: [], body: smsText)
        )
        return .none

      case .binding(\.$searchQuery):
        let username = state.searchQuery.lowercased()
        guard username.count >= 4 else {
          state.searchResult = []
          return .cancel(id: Cancel.search)
        }
        return .run { send in
          try await withTaskCancellation(id: Cancel.search, cancelInFlight: true) {
            try await mainQueue.sleep(for: .seconds(1))

            for try await data in godClient.userSearch(username) {
              await send(.searchResponse(.success(data)))
            }
          }
        } catch: { error, send in
          await send(.searchResponse(.failure(error)))
        }
      case let .searchResponse(.success(data)):
        let username = data.userSearch.username ?? ""
        state.searchResult = [
          .init(
            id: data.userSearch.id,
            imageURL: data.userSearch.imageURL,
            displayName: data.userSearch.displayName.ja,
            firstName: data.userSearch.firstName,
            lastName: data.userSearch.lastName,
            description: "@\(username)",
            friendStatus: data.userSearch.friendStatus.value
          ),
        ]
        return .none
      case .searchResponse(.failure):
        state.searchResult = []
        return .none
      case let .addPlusResponse(.success(data)):
        let friendRequests = data.friendRequests.edges.map {
          FriendRequestCardLogic.State(
            friendId: $0.node.id,
            userId: $0.node.user.id,
            imageURL: $0.node.user.imageURL,
            displayName: $0.node.user.displayName.ja,
            firstName: $0.node.user.firstName,
            lastName: $0.node.user.lastName,
            description: String(localized: "\($0.node.user.mutualFriendsCount) mutual friends", bundle: .module)
          )
        }
        let friendsOfFriends = data.friendsOfFriends
          .edges
          .filter {
            $0.node.friendStatus.value == God.FriendStatus.canceled ||
              $0.node.friendStatus.value == God.FriendStatus.unspecified
          }
          .map {
            FriendRowCardLogic.State(
              id: $0.node.id,
              imageURL: $0.node.imageURL,
              displayName: $0.node.displayName.ja,
              firstName: $0.node.firstName,
              lastName: $0.node.lastName,
              description: String(localized: "\($0.node.mutualFriendsCount) mutual friends", bundle: .module),
              friendStatus: $0.node.friendStatus.value
            )
          }
        let fromSchools = data.usersBySameSchool
          .edges
          .filter {
            $0.node.friendStatus.value == God.FriendStatus.canceled ||
              $0.node.friendStatus.value == God.FriendStatus.unspecified
          }
          .map {
            FriendRowCardLogic.State(
              id: $0.node.id,
              imageURL: $0.node.imageURL,
              displayName: $0.node.displayName.ja,
              firstName: $0.node.firstName,
              lastName: $0.node.lastName,
              description: $0.node.grade ?? "",
              friendStatus: $0.node.friendStatus.value
            )
          }
        state.friendRequestPanel = friendRequests.isEmpty ? nil : .init(requests: .init(uniqueElements: friendRequests))
        state.friendsOfFriendsPanel = friendsOfFriends.isEmpty ? nil : .init(friendsOfFriends: .init(uniqueElements: friendsOfFriends))
        state.fromSchoolPanel = fromSchools.isEmpty ? nil : .init(users: .init(uniqueElements: fromSchools))
        state.currentUser = data.currentUser
        if let username = data.currentUser.username {
          state.shareURL = ShareLinkBuilder.buildGodLink(path: .invite, username: username, source: .share, medium: .add)
        }
        return .run { send in
          await profileImageRequest(send: send, data: data.currentUser.fragments.profileStoryFragment)
        }
      case .addPlusResponse(.failure):
        state.friendRequestPanel = nil
        state.friendsOfFriendsPanel = nil
        state.fromSchoolPanel = nil
        state.currentUser = nil
        return .none

      case let .profileImageResponse(.success(data)):
        state.profileImageData = data
        return .none

      case let .schoolImageResponse(.success(data)):
        state.schoolImageData = data
        return .none

      case let .friendRequestPanel(.delegate(.showExternalProfile(userId))):
        state.destination = .profileExternal(
          ProfileExternalLogic.State(userId: userId)
        )
        return .none

      case .friendRequestPanel(.requests(_, .delegate(.approved))):
        return .run { send in
          await addPlusRequest(send: send)
        }

      case let .friendsOfFriendsPanel(.delegate(.showExternalProfile(userId))):
        state.destination = .profileExternal(
          ProfileExternalLogic.State(userId: userId)
        )
        return .none

      case .friendsOfFriendsPanel(.friendsOfFriends(_, .delegate(.requested))):
        return .run { send in
          await addPlusRequest(send: send)
        }

      case let .fromSchoolPanel(.delegate(.showExternalProfile(userId))):
        state.destination = .profileExternal(
          ProfileExternalLogic.State(userId: userId)
        )
        return .none

      case .fromSchoolPanel(.users(_, .delegate(.requested))):
        return .run { send in
          await addPlusRequest(send: send)
        }

      default:
        return .none
      }
    }
    .forEach(\.searchResult, action: /Action.searchResult) {
      FriendRowCardLogic()
    }
    .ifLet(\.contactsReEnable, action: /Action.contactsReEnable) {
      ContactsReEnableLogic()
    }
    .ifLet(\.friendsOfFriendsPanel, action: /Action.friendsOfFriendsPanel) {
      FriendsOfFriendsPanelLogic()
    }
    .ifLet(\.friendRequestPanel, action: /Action.friendRequestPanel) {
      FriendRequestsLogic()
    }
    .ifLet(\.fromSchoolPanel, action: /Action.fromSchoolPanel) {
      FromSchoolPanelLogic()
    }
    .ifLet(\.$destination, action: /Action.destination) {
      Destination()
    }
  }

  private func addPlusRequest(send: Send<Action>) async {
    do {
      for try await data in godClient.addPlus() {
        await send(.addPlusResponse(.success(data)))
      }
    } catch {
      await send(.addPlusResponse(.failure(error)))
    }
  }

  private func profileImageRequest(send: Send<Action>, data: God.ProfileStoryFragment) async {
    await withTaskGroup(of: Void.self) { group in
      if let imageURL = URL(string: data.imageURL) {
        group.addTask {
          do {
            let (data, _) = try await urlSession.data(from: imageURL)
            await send(.profileImageResponse(.success(data)))
          } catch {
            await send(.profileImageResponse(.failure(error)))
          }
        }
      }
      if let imageURL = URL(string: data.school?.profileImageURL ?? "") {
        group.addTask {
          do {
            let (data, _) = try await urlSession.data(from: imageURL)
            await send(.schoolImageResponse(.success(data)))
          } catch {
            await send(.schoolImageResponse(.failure(error)))
          }
        }
      }
    }
  }
}

public struct AddView: View {
  let store: StoreOf<AddLogic>
  @Environment(\.displayScale) var displayScale

  public init(store: StoreOf<AddLogic>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      let instagramStoryView = instagramStoryView(
        profileImageData: viewStore.profileImageData,
        schoolImageData: viewStore.schoolImageData,
        fragment: viewStore.currentUser?.fragments.profileStoryFragment
      )
      ZStack {
        VStack(spacing: 0) {
          IfLetStore(
            store.scope(state: \.contactsReEnable, action: AddLogic.Action.contactsReEnable),
            then: ContactsReEnableView.init(store:)
          )
          SearchField(text: viewStore.$searchQuery)

          Divider()

          ScrollView {
            LazyVStack(spacing: 0) {
              FriendHeader(title: "SHARE PROFILE")
              SocialShare(
                shareURL: viewStore.shareURL,
                storyAction: {
                  let renderer = ImageRenderer(content: instagramStoryView)
                  renderer.scale = displayScale
                  store.send(.storyButtonTapped(renderer.uiImage))
                },
                lineAction: {
                  store.send(.lineButtonTapped)
                },
                messageAction: {
                  store.send(.messageButtonTapped)
                }
              )
              .padding(.vertical, 12)
              .padding(.horizontal, 24)

              Divider()

              if viewStore.searchResult.isEmpty {
                IfLetStore(
                  store.scope(state: \.friendRequestPanel, action: AddLogic.Action.friendRequestPanel),
                  then: FriendRequestsView.init(store:)
                )
                IfLetStore(
                  store.scope(state: \.friendsOfFriendsPanel, action: AddLogic.Action.friendsOfFriendsPanel),
                  then: FriendsOfFriendsPanelView.init(store:)
                )
                IfLetStore(
                  store.scope(state: \.fromSchoolPanel, action: AddLogic.Action.fromSchoolPanel),
                  then: FromSchoolPanelView.init(store:)
                )
                InvitationsLeftView(
                  store: store.scope(
                    state: \.invitationsLeft,
                    action: AddLogic.Action.invitationsLeft
                  )
                )
              } else {
                ForEachStore(
                  store.scope(state: \.searchResult, action: AddLogic.Action.searchResult)
                ) {
                  FriendRowCardView(store: $0)
                }
              }
            }
          }
        }
      }
      .task { await store.send(.onTask).finish() }
      .onAppear { store.send(.onAppear) }
      .sheet(
        store: store.scope(state: \.$destination, action: AddLogic.Action.destination),
        state: /AddLogic.Destination.State.message,
        action: AddLogic.Destination.Action.message,
        content: CupertinoMessageView.init
      )
      .sheet(
        store: store.scope(state: \.$destination, action: AddLogic.Action.destination),
        state: /AddLogic.Destination.State.profileExternal,
        action: AddLogic.Destination.Action.profileExternal
      ) { store in
        NavigationStack {
          ProfileExternalView(store: store)
        }
      }
    }
  }

  @ViewBuilder
  func instagramStoryView(
    profileImageData: Data?,
    schoolImageData: Data?,
    fragment: God.ProfileStoryFragment?
  ) -> some View {
    if let fragment {
      ProfileStoryView(
        profileImageData: profileImageData,
        firstName: fragment.firstName,
        displayName: fragment.displayName.ja,
        username: fragment.username,
        schoolImageData: schoolImageData,
        schoolName: fragment.school?.name
      )
    }
  }
}

#Preview {
  AddView(
    store: .init(
      initialState: AddLogic.State(),
      reducer: { AddLogic() }
    )
  )
}
