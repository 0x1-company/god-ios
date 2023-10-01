import ComposableArchitecture
import God
import GodClient
import SwiftUI

public struct FriendsOfFriendsPanelLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    var friendsOfFriends: IdentifiedArrayOf<FriendRowCardLogic.State>

    public init(friendsOfFriends: IdentifiedArrayOf<FriendRowCardLogic.State>) {
      self.friendsOfFriends = friendsOfFriends
    }
  }

  public enum Action: Equatable {
    case friendsOfFriends(id: FriendRowCardLogic.State.ID, action: FriendRowCardLogic.Action)
  }

  public var body: some Reducer<State, Action> {
    Reduce<State, Action> { _, action in
      switch action {
      case .friendsOfFriends:
        return .none
      }
    }
    .forEach(\.friendsOfFriends, action: /Action.friendsOfFriends) {
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
    WithViewStore(store, observe: { $0 }) { viewStore in
      VStack(spacing: 0) {
        FriendHeader(title: "FRIENDS OF FRIENDS")

        ForEachStore(
          store.scope(state: \.friendsOfFriends, action: FriendsOfFriendsPanelLogic.Action.friendsOfFriends)
        ) {
          FriendRowCardView(store: $0)
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
