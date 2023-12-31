import ComposableArchitecture
import God
import GodClient
import Styleguide
import SwiftUI

@Reducer
public struct FriendRequestsLogic {
  public init() {}

  public struct State: Equatable {
    var requests: IdentifiedArrayOf<FriendRequestCardLogic.State> = []

    public init(requests: IdentifiedArrayOf<FriendRequestCardLogic.State>) {
      self.requests = requests
    }
  }

  public enum Action {
    case onTask
    case requests(IdentifiedActionOf<FriendRequestCardLogic>)
    case cardButtonTapped(String)
    case delegate(Delegate)

    public enum Delegate: Equatable {
      case showExternalProfile(userId: String)
    }
  }

  @Dependency(\.godClient) var godClient

  enum Cancel {
    case friendRequests
  }

  public var body: some Reducer<State, Action> {
    Reduce<State, Action> { _, action in
      switch action {
      case .onTask:
        return .none

      case .requests:
        return .none

      case let .cardButtonTapped(userId):
        return .send(.delegate(.showExternalProfile(userId: userId)), animation: .default)

      case .delegate:
        return .none
      }
    }
    .forEach(\.requests, action: \.requests) {
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
      LazyVStack(spacing: 0) {
        FriendHeader(title: "FRIEND REQUESTS")

        ForEachStore(
          store.scope(state: \.requests, action: \.requests)
        ) { cardStore in
          WithViewStore(cardStore, observe: { $0 }) { viewStore in
            FriendRequestCardView(store: cardStore)
              .onTapGesture {
                store.send(.cardButtonTapped(viewStore.userId))
              }
          }
        }
      }
      .task { await store.send(.onTask).finish() }
    }
  }
}

#Preview {
  FriendRequestsView(
    store: .init(
      initialState: FriendRequestsLogic.State(
        requests: []
      ),
      reducer: { FriendRequestsLogic() }
    )
  )
}
