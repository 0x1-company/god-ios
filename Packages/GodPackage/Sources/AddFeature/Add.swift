import Colors
import ComposableArchitecture
import Contacts
import ContactsClient
import SwiftUI
import UIApplicationClient
import God
import GodClient

public struct AddLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    var contactsReEnableCardVisible = false
    @BindingState var searchQuery = ""

    var invitationsLeft = InvitationsLeftLogic.State()
    var friendRequests = FriendRequestsLogic.State()
    var friendsOfFriends = FriendsOfFriendsPanelLogic.State()
    
    var searchResult: IdentifiedArrayOf<FriendRowCardLogic.State> = []
    public init() {}
  }

  public enum Action: Equatable, BindableAction {
    case onTask
    case refreshable
    case contactsReEnableButtonTapped
    case searchResponse(TaskResult<God.UserQuery.Data>)
    case binding(BindingAction<State>)
    case invitationsLeft(InvitationsLeftLogic.Action)
    case friendRequests(FriendRequestsLogic.Action)
    case friendsOfFriends(FriendsOfFriendsPanelLogic.Action)
    case searchResult(id: FriendRowCardLogic.State.ID, action: FriendRowCardLogic.Action)
  }

  @Dependency(\.openURL) var openURL
  @Dependency(\.mainQueue) var mainQueue
  @Dependency(\.godClient) var godClient
  @Dependency(\.application.openSettingsURLString) var openSettingsURLString
  @Dependency(\.contacts.authorizationStatus) var contactsAuthorizationStatus
  
  enum Cancel {
    case search
  }

  public var body: some Reducer<State, Action> {
    BindingReducer()
    Scope(state: \.invitationsLeft, action: /Action.invitationsLeft) {
      InvitationsLeftLogic()
    }
    Scope(state: \.friendRequests, action: /Action.friendRequests) {
      FriendRequestsLogic()
    }
    Scope(state: \.friendsOfFriends, action: /Action.friendsOfFriends) {
      FriendsOfFriendsPanelLogic()
    }
    Reduce<State, Action> { state, action in
      switch action {
      case .onTask:
        return .none

      case .refreshable:
        return .run { _ in
          try await mainQueue.sleep(for: .seconds(3))
        }
      case .contactsReEnableButtonTapped:
        return .run { _ in
          let settingsURLString = await openSettingsURLString()
          guard let url = URL(string: settingsURLString)
          else { return }
          await openURL(url)
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
            description: "@\(username)"
          )
        ]
        return .none
      case .searchResponse(.failure):
        state.searchResult = []
        return .none
      default:
        return .none
      }
    }
    Reduce<State, Action> { state, _ in
      state.contactsReEnableCardVisible = contactsAuthorizationStatus(.contacts) != .authorized
      return .none
    }
    .forEach(\.searchResult, action: /Action.searchResult) {
      FriendRowCardLogic()
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
        if viewStore.contactsReEnableCardVisible {
          ContactsReEnableCard {
            viewStore.send(.contactsReEnableButtonTapped)
          }
        }
        SearchField(text: viewStore.$searchQuery)
        Divider()

        ScrollView {
          LazyVStack(spacing: 0) {
            if viewStore.searchResult.isEmpty {
              InvitationsLeftView(store: store.scope(state: \.invitationsLeft, action: AddLogic.Action.invitationsLeft))
              FriendRequestsView(store: store.scope(state: \.friendRequests, action: AddLogic.Action.friendRequests))
              FriendsOfFriendsPanelView(store: store.scope(state: \.friendsOfFriends, action: AddLogic.Action.friendsOfFriends))
              VStack(spacing: 0) {
                FriendHeader(title: "FROM SCHOOL")
              }
            } else {
              ForEachStore(
                store.scope(state: \.searchResult, action: AddLogic.Action.searchResult)
              ) {
                FriendRowCardView(store: $0)
              }
            }
          }
        }
        .refreshable { await viewStore.send(.refreshable).finish() }
      }
      .task { await viewStore.send(.onTask).finish() }
    }
  }
}

struct AddViewPreviews: PreviewProvider {
  static var previews: some View {
    AddView(
      store: .init(
        initialState: AddLogic.State(),
        reducer: { AddLogic() }
      )
    )
  }
}
