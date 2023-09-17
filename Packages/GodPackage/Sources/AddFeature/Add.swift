import Colors
import ComposableArchitecture
import Contacts
import ContactsClient
import SwiftUI
import UIApplicationClient

public struct AddLogic: Reducer {
  public init() {}
  
  public struct State: Equatable {
    var contactsReEnableCardVisible = false
    @BindingState var searchQuery = ""
    
    var invitationsLeft = InvitationsLeftLogic.State()
    var friendRequests = FriendRequestsLogic.State()
    var friendsOfFriends = FriendsOfFriendsPanelLogic.State()
    public init() {}
  }
  
  public enum Action: Equatable, BindableAction {
    case onTask
    case refreshable
    case contactsReEnableButtonTapped
    case binding(BindingAction<State>)
    case invitationsLeft(InvitationsLeftLogic.Action)
    case friendRequests(FriendRequestsLogic.Action)
    case friendsOfFriends(FriendsOfFriendsPanelLogic.Action)
  }
  
  @Dependency(\.openURL) var openURL
  @Dependency(\.mainQueue) var mainQueue
  @Dependency(\.application.openSettingsURLString) var openSettingsURLString
  @Dependency(\.contacts.authorizationStatus) var contactsAuthorizationStatus
  
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
      default:
        return .none
      }
    }
    Reduce<State, Action> { state, _ in
      state.contactsReEnableCardVisible = contactsAuthorizationStatus(.contacts) != .authorized
      return .none
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
            InvitationsLeftView(store: store.scope(state: \.invitationsLeft, action: AddLogic.Action.invitationsLeft))
            FriendRequestsView(store: store.scope(state: \.friendRequests, action: AddLogic.Action.friendRequests))
            FriendsOfFriendsPanelView(store: store.scope(state: \.friendsOfFriends, action: AddLogic.Action.friendsOfFriends))
            VStack(spacing: 0) {
              FriendHeader(title: "FROM SCHOOL")
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
