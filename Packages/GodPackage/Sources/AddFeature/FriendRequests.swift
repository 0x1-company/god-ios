import ButtonStyles
import Colors
import ComposableArchitecture
import SwiftUI

public struct FriendRequestsLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    var requests: IdentifiedArrayOf<FriendRequestCardLogic.State> = []
    public init() {}
  }

  public enum Action: Equatable {
    case onTask
    case requests(id: FriendRequestCardLogic.State.ID, action: FriendRequestCardLogic.Action)
  }

  public var body: some Reducer<State, Action> {
    Reduce<State, Action> { _, action in
      switch action {
      case .onTask:
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
