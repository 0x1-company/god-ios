import ComposableArchitecture
import God
import GodClient
import SwiftUI

@Reducer
public struct FriendsOfFriendsPanelLogic {
  public init() {}

  public struct State: Equatable {
    var friendsOfFriends: IdentifiedArrayOf<FriendRowCardLogic.State>

    public init(friendsOfFriends: IdentifiedArrayOf<FriendRowCardLogic.State>) {
      self.friendsOfFriends = friendsOfFriends
    }
  }

  public enum Action {
    case friendsOfFriends(id: FriendRowCardLogic.State.ID, action: FriendRowCardLogic.Action)
    case cardButtonTapped(String)
    case delegate(Delegate)

    public enum Delegate: Equatable {
      case showExternalProfile(userId: String)
    }
  }

  public var body: some Reducer<State, Action> {
    Reduce<State, Action> { _, action in
      switch action {
      case .friendsOfFriends:
        return .none

      case let .cardButtonTapped(userId):
        return .send(.delegate(.showExternalProfile(userId: userId)), animation: .default)

      case .delegate:
        return .none
      }
    }
    .forEach(\.friendsOfFriends, action: \.friendsOfFriends) {
      FriendRowCardLogic()
    }
  }
}

public struct FriendsOfFriendsPanelView: View {
  let store: StoreOf<FriendsOfFriendsPanelLogic>

  public init(store: StoreOf<FriendsOfFriendsPanelLogic>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { _ in
      LazyVStack(spacing: 0) {
        FriendHeader(title: "FRIENDS OF FRIENDS")

        ForEachStore(
          store.scope(state: \.friendsOfFriends, action: FriendsOfFriendsPanelLogic.Action.friendsOfFriends)
        ) { cardStore in
          WithViewStore(cardStore, observe: { $0 }) { viewStore in
            FriendRowCardView(store: cardStore)
              .onTapGesture {
                store.send(.cardButtonTapped(viewStore.id))
              }
          }
        }

//        Button {} label: {
//          Text("See \(viewStore.friendsOfFriends.count) more", bundle: .module)
//        }
//        .buttonStyle(SeeMoreButtonStyle())
      }
    }
  }
}

#Preview {
  FriendsOfFriendsPanelView(
    store: .init(
      initialState: FriendsOfFriendsPanelLogic.State(
        friendsOfFriends: []
      ),
      reducer: { FriendsOfFriendsPanelLogic() }
    )
  )
}
