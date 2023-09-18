import ButtonStyles
import Colors
import ComposableArchitecture
import God
import GodClient
import SwiftUI

public struct FriendRequestsLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    var requests: IdentifiedArrayOf<FriendRequestCardLogic.State> = []
    public init() {}
  }

  public enum Action: Equatable {
    case onTask
    case friendRequestResponse(TaskResult<God.FriendRequestsQuery.Data>)
    case requests(id: FriendRequestCardLogic.State.ID, action: FriendRequestCardLogic.Action)
  }

  @Dependency(\.godClient) var godClient

  enum Cancel {
    case friendRequests
  }

  public var body: some Reducer<State, Action> {
    Reduce<State, Action> { state, action in
      switch action {
      case .onTask:
        return .run { send in
          for try await data in godClient.friendRequests() {
            await send(.friendRequestResponse(.success(data)))
          }
        } catch: { error, send in
          await send(.friendRequestResponse(.failure(error)))
        }
        .cancellable(id: Cancel.friendRequests)

      case let .friendRequestResponse(.success(data)):
        let requests = data.friendRequests.edges
          .map(\.node.fragments.friendRequestCardFragment)
          .map { data in
            FriendRequestCardLogic.State(
              friendId: data.id,
              userId: data.user.id,
              displayName: data.user.displayName.ja,
              description: "\(data.user.mutualFriendsCount) mutual friend"
            )
          }
        state.requests = .init(uniqueElements: requests)
        return .none
      case .friendRequestResponse(.failure):
        state.requests = []
        return .none

      case .requests:
        return .none
      }
    }
    .forEach(\.requests, action: /Action.requests) {
      FriendRequestCardLogic()
    }
  }
}

public struct FriendRequestsView: View {
  let store: StoreOf<FriendRequestsLogic>

  public init(store: StoreOf<FriendRequestsLogic>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      VStack(spacing: 0) {
        FriendHeader(title: "FRIEND REQUESTS")

        ForEachStore(
          store.scope(state: \.requests, action: FriendRequestsLogic.Action.requests),
          content: FriendRequestCardView.init(store:)
        )
      }
      .task { await viewStore.send(.onTask).finish() }
    }
  }
}

struct FriendRequestsViewPreviews: PreviewProvider {
  static var previews: some View {
    FriendRequestsView(
      store: .init(
        initialState: FriendRequestsLogic.State(),
        reducer: { FriendRequestsLogic() }
      )
    )
  }
}
