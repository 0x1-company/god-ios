import Colors
import ComposableArchitecture
import Contacts
import ContactsClient
import SwiftUI
import UIApplicationClient

public struct AddLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    @PresentationState var destination: Destination.State?
    var contactsReEnableCardVisible = false
    @BindingState var searchQuery = ""

    var invitationsLeft = InvitationsLeftLogic.State()
    var friendRequests = FriendRequestsLogic.State()

    var friendsOfFriends: IdentifiedArrayOf<FriendRequestCardLogic.State> = []
    public init() {}
  }

  public enum Action: Equatable, BindableAction {
    case onTask
    case refreshable
    case contactsReEnableButtonTapped
    case seeMoreFriendsOfFriendsButtonTapped
    case seeMoreFromSchoolButtonTapped
    case binding(BindingAction<State>)
    case destination(PresentationAction<Destination.Action>)
    case invitationsLeft(InvitationsLeftLogic.Action)
    case friendRequests(FriendRequestsLogic.Action)
    case friendsOfFriends(id: FriendRequestCardLogic.State.ID, action: FriendRequestCardLogic.Action)
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
      case .seeMoreFriendsOfFriendsButtonTapped:
        state.destination = .friendsOfFriends()
        return .none

      case .seeMoreFromSchoolButtonTapped:
        state.destination = .fromSchool()
        return .none

      case .binding:
        return .none

      case .destination:
        return .none

      case .invitationsLeft:
        return .none

      case .friendRequests:
        return .none

      case .friendsOfFriends:
        return .none
      }
    }
    Reduce<State, Action> { state, _ in
      state.contactsReEnableCardVisible = contactsAuthorizationStatus(.contacts) != .authorized
      return .none
    }
    .ifLet(\.$destination, action: /Action.destination) {
      Destination()
    }
    .forEach(\.friendsOfFriends, action: /Action.friendsOfFriends) {
      FriendRequestCardLogic()
    }
  }

  public struct Destination: Reducer {
    public enum State: Equatable {
      case friendsOfFriends(FriendsOfFriendsLogic.State = .init())
      case fromSchool(FromSchoolLogic.State = .init())
    }

    public enum Action: Equatable {
      case friendsOfFriends(FriendsOfFriendsLogic.Action)
      case fromSchool(FromSchoolLogic.Action)
    }

    public var body: some Reducer<State, Action> {
      Scope(state: /State.friendsOfFriends, action: /Action.friendsOfFriends) {
        FriendsOfFriendsLogic()
      }
      Scope(state: /State.fromSchool, action: /Action.fromSchool) {
        FromSchoolLogic()
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
        if viewStore.contactsReEnableCardVisible {
          ContactsReEnableCard {
            viewStore.send(.contactsReEnableButtonTapped)
          }
        }
        SearchField(text: viewStore.$searchQuery)
        Divider()

        ScrollView {
          LazyVStack(spacing: 0) {
            InvitationsLeftView(
              store: store.scope(
                state: \.invitationsLeft,
                action: AddLogic.Action.invitationsLeft
              )
            )
            FriendRequestsView(
              store: store.scope(
                state: \.friendRequests,
                action: AddLogic.Action.friendRequests
              )
            )
            VStack(spacing: 0) {
              FriendHeader(title: "FRIENDS OF FRIENDS")
              ForEachStore(
                store.scope(state: \.friendsOfFriends, action: AddLogic.Action.friendsOfFriends),
                content: FriendRequestCardView.init(store:)
              )
              Button("See 19 more") {
                viewStore.send(.seeMoreFriendsOfFriendsButtonTapped)
              }
              .buttonStyle(SeeMoreButtonStyle())
            }
            VStack(spacing: 0) {
              FriendHeader(title: "FROM SCHOOL")
              ForEachStore(
                store.scope(state: \.friendsOfFriends, action: AddLogic.Action.friendsOfFriends),
                content: FriendRequestCardView.init(store:)
              )
              Button("See 471 more") {
                viewStore.send(.seeMoreFromSchoolButtonTapped)
              }
              .buttonStyle(SeeMoreButtonStyle())
            }
          }
        }
        .refreshable { await viewStore.send(.refreshable).finish() }
      }
      .task { await viewStore.send(.onTask).finish() }
      .sheet(
        store: store.scope(state: \.$destination, action: { .destination($0) })
      ) { store in
        SwitchStore(store) {
          switch $0 {
          case .friendsOfFriends:
            CaseLet(
              /AddLogic.Destination.State.friendsOfFriends,
              action: AddLogic.Destination.Action.friendsOfFriends
            ) { store in
              NavigationStack {
                FriendsOfFriendsView(store: store)
              }
            }
          case .fromSchool:
            CaseLet(
              /AddLogic.Destination.State.fromSchool,
              action: AddLogic.Destination.Action.fromSchool
            ) { store in
              NavigationStack {
                FromSchoolView(store: store)
              }
            }
          }
        }
      }
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
