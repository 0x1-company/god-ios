import ComposableArchitecture
import God
import GodClient
import SwiftUI

public struct FriendsOfFriendsPanelLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    var friendsOfFriends: IdentifiedArrayOf<FriendRowCardLogic.State> = []
    public init() {}
  }

  public enum Action: Equatable {
    case onTask
    case friendsOfFriendsResponse(TaskResult<God.FriendsOfFriendsQuery.Data>)
    case friendsOfFriends(id: FriendRowCardLogic.State.ID, action: FriendRowCardLogic.Action)
  }

  @Dependency(\.godClient) var godClient

  enum Cancel {
    case id
  }

  public var body: some Reducer<State, Action> {
    Reduce<State, Action> { state, action in
      switch action {
      case .onTask:
        return .run { send in
          for try await data in godClient.friendsOfFriends() {
            await send(.friendsOfFriendsResponse(.success(data)))
          }
        } catch: { error, send in
          await send(.friendsOfFriendsResponse(.failure(error)))
        }
        .cancellable(id: Cancel.id)
      case let .friendsOfFriendsResponse(.success(data)):
        let friendsOfFriends = data.friendsOfFriends.edges
          .map(\.node.fragments.friendsOfFriendsCardFragment)
          .map { data in
            let mutualFriendsCount = data.mutualFriendsCount ?? 0
            return FriendRowCardLogic.State(
              id: data.id,
              displayName: data.displayName.ja,
              description: mutualFriendsCount.description
            )
          }
        state.friendsOfFriends = .init(uniqueElements: friendsOfFriends)
        return .none

      case .friendsOfFriendsResponse(.failure):
        state.friendsOfFriends = []
        return .none

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
      }
      .task { await viewStore.send(.onTask).finish() }
    }
  }
}

#Preview {
  FriendsOfFriendsPanelView(
    store: .init(
      initialState: FriendsOfFriendsPanelLogic.State(),
      reducer: { FriendsOfFriendsPanelLogic() }
    )
  )
}
