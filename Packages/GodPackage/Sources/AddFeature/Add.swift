import Colors
import ComposableArchitecture
import Contacts
import ContactsClient
import God
import GodClient
import SearchField
import SwiftUI
import UIApplicationClient

public struct AddLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    @BindingState var searchQuery = ""

    var contactsReEnable: ContactsReEnableLogic.State?
    var invitationsLeft = InvitationsLeftLogic.State()
    var friendRequestPanel: FriendRequestsLogic.State?
    var friendsOfFriendsPanel: FriendsOfFriendsPanelLogic.State?
    var fromSchoolPanel: FromSchoolPanelLogic.State?

    var searchResult: IdentifiedArrayOf<FriendRowCardLogic.State> = []
    public init() {}
  }

  public enum Action: Equatable, BindableAction {
    case onTask
    case searchResponse(TaskResult<God.UserQuery.Data>)
    case addPlusResponse(TaskResult<God.AddPlusQuery.Data>)
    case binding(BindingAction<State>)
    case contactsReEnable(ContactsReEnableLogic.Action)
    case invitationsLeft(InvitationsLeftLogic.Action)
    case friendRequestPanel(FriendRequestsLogic.Action)
    case friendsOfFriendsPanel(FriendsOfFriendsPanelLogic.Action)
    case fromSchoolPanel(FromSchoolPanelLogic.Action)
    case searchResult(id: FriendRowCardLogic.State.ID, action: FriendRowCardLogic.Action)
  }

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
          for try await data in godClient.addPlus() {
            await send(.addPlusResponse(.success(data)))
          }
        } catch: { error, send in
          await send(.addPlusResponse(.failure(error)))
        }
      case .binding(\.$searchQuery):
        let username = state.searchQuery.lowercased()
        guard username.count >= 4 else {
          state.searchResult = []
          return .none
        }
        let userWhere = God.UserWhere(
          username: .init(stringLiteral: username)
        )
        return .run { send in
          for try await data in godClient.user(userWhere) {
            await send(.searchResponse(.success(data)))
          }
        } catch: { error, send in
          await send(.searchResponse(.failure(error)))
        }
        .cancellable(id: Cancel.search, cancelInFlight: true)
      case let .searchResponse(.success(data)):
        let username = data.user.username ?? ""
        state.searchResult = [
          .init(
            id: data.user.id,
            displayName: data.user.displayName.ja,
            firstName: data.user.firstName,
            lastName: data.user.lastName,
            description: "@\(username)"
          ),
        ]
        return .none
      case .searchResponse(.failure):
        state.searchResult = []
        return .none
      case let .addPlusResponse(.success(data)):
        let friendRequests = data.friendRequests.edges.map {
          FriendRequestCardLogic.State(friendId: $0.node.id, userId: $0.node.user.id, displayName: $0.node.user.displayName.ja, description: String(localized: "\($0.node.user.mutualFriendsCount) mutual friends", bundle: .module))
        }
        let friendsOfFriends = data.friendsOfFriends.edges.map {
          FriendRowCardLogic.State(
            id: $0.node.id,
            displayName: $0.node.displayName.ja,
            firstName: $0.node.firstName,
            lastName: $0.node.lastName,
            description: String(localized: "\($0.node.mutualFriendsCount) mutual friends", bundle: .module)
          )
        }
        let fromSchools = data.fromSchool.edges.map {
          FriendRowCardLogic.State(
            id: $0.node.id,
            displayName: $0.node.displayName.ja,
            firstName: $0.node.firstName,
            lastName: $0.node.lastName,
            description: $0.node.grade ?? ""
          )
        }
        state.friendRequestPanel = friendRequests.isEmpty ? nil : .init(requests: .init(uniqueElements: friendRequests))
        state.friendsOfFriendsPanel = friendsOfFriends.isEmpty ? nil : .init(friendsOfFriends: .init(uniqueElements: friendsOfFriends))
        state.fromSchoolPanel = fromSchools.isEmpty ? nil : .init(users: .init(uniqueElements: fromSchools))
        return .none
      case .addPlusResponse(.failure):
        state.friendRequestPanel = nil
        state.friendsOfFriendsPanel = nil
        state.fromSchoolPanel = nil
        return .none
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
