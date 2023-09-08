import ButtonStyles
import Colors
import ComposableArchitecture
import SwiftUI

public struct FriendRequestsLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    public init() {}
  }

  public enum Action: Equatable {
    case onTask
  }

  public var body: some ReducerOf<Self> {
    Reduce { _, action in
      switch action {
      case .onTask:
        return .none
      }
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

        FriendRequestCardView(
          store: .init(
            initialState: FriendRequestCardLogic.State(),
            reducer: { FriendRequestCardLogic() }
          )
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
