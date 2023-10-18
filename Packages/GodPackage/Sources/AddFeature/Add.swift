import ComposableArchitecture
import Contacts
import ContactsClient
import God
import GodClient
import ProfileFeature
import SearchField
import Styleguide
import SwiftUI
import UIApplicationClient

public struct AddLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    @BindingState var searchQuery = ""
    @PresentationState var destination: Destination.State?

    var contactsReEnable: ContactsReEnableLogic.State?
    var invitationsLeft = InvitationsLeftLogic.State()
    var friendRequestPanel: FriendRequestsLogic.State?
    var friendsOfFriendsPanel: FriendsOfFriendsPanelLogic.State?
    var fromSchoolPanel: FromSchoolPanelLogic.State?

    var currentUser: God.AddPlusQuery.Data.CurrentUser?
    var searchResult: IdentifiedArrayOf<FriendRowCardLogic.State> = []
    public init() {}
  }

  public enum Action: Equatable, BindableAction {
    case onTask
    case searchResponse(TaskResult<God.UserSearchQuery.Data>)
    case addPlusResponse(TaskResult<God.AddPlusQuery.Data>)
    case binding(BindingAction<State>)
    case contactsReEnable(ContactsReEnableLogic.Action)
    case invitationsLeft(InvitationsLeftLogic.Action)
    case friendRequestPanel(FriendRequestsLogic.Action)
    case friendsOfFriendsPanel(FriendsOfFriendsPanelLogic.Action)
    case fromSchoolPanel(FromSchoolPanelLogic.Action)
    case searchResult(id: FriendRowCardLogic.State.ID, action: FriendRowCardLogic.Action)
    case destination(PresentationAction<Destination.Action>)
  }

  @Dependency(\.mainQueue) var mainQueue
  @Dependency(\.godClient) var godClient
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
        let friendsOfFriends = data.friendsOfFriends.edges.map {
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
        let fromSchools = data.usersBySameSchool.edges.map {
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
        return .none
      case .addPlusResponse(.failure):
        state.friendRequestPanel = nil
        state.friendsOfFriendsPanel = nil
        state.fromSchoolPanel = nil
        state.currentUser = nil
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

  public struct Destination: Reducer {
    public enum State: Equatable {
      case profileExternal(ProfileExternalLogic.State)
    }

    public enum Action: Equatable {
      case profileExternal(ProfileExternalLogic.Action)
    }

    public var body: some Reducer<State, Action> {
      Scope(state: /State.profileExternal, action: /Action.profileExternal) {
        ProfileExternalLogic()
      }
    }
  }
}

public struct AddView: View {
  let store: StoreOf<AddLogic>

  public init(store: StoreOf<AddLogic>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      VStack(spacing: 0) {
        IfLetStore(
          store.scope(state: \.contactsReEnable, action: AddLogic.Action.contactsReEnable),
          then: ContactsReEnableView.init(store:)
        )
        SearchField(text: viewStore.$searchQuery)
        Divider()

        ScrollView {
          LazyVStack(spacing: 0) {
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
      .task { await viewStore.send(.onTask).finish() }
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
}

#Preview {
  AddView(
    store: .init(
      initialState: AddLogic.State(),
      reducer: { AddLogic() }
    )
  )
}
