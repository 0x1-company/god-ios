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

    public init(requests: IdentifiedArrayOf<FriendRequestCardLogic.State>) {
      self.requests = requests
    }
  }

  public enum Action: Equatable {
    case onTask
    case requests(id: FriendRequestCardLogic.State.ID, action: FriendRequestCardLogic.Action)
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
      LazyVStack(spacing: 0) {
        FriendHeader(title: "FRIEND REQUESTS")
        
        ForEachStore(
          store.scope(state: \.requests, action: FriendRequestsLogic.Action.requests)
        ) { cardStore in
          WithViewStore(cardStore, observe: { $0 }) { viewStore in
            FriendRequestCardView(store: cardStore)
              .onTapGesture {
                store.send(.cardButtonTapped(viewStore.userId))
              }
          }
        }
      }
      .task { await viewStore.send(.onTask).finish() }
    }
  }
}

struct FriendRequestsViewPreviews: PreviewProvider {
  static var previews: some View {
    FriendRequestsView(
      store: .init(
        initialState: FriendRequestsLogic.State(
          requests: []
        ),
        reducer: { FriendRequestsLogic() }
      )
    )
  }
}
