import ComposableArchitecture
import SwiftUI

public struct FriendsOfFriendsLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    @BindingState var searchQuery = ""
    var requests: IdentifiedArrayOf<FriendRequestCardLogic.State> = []
    public init() {}
  }

  public enum Action: Equatable, BindableAction {
    case onTask
    case closeButtonTapped
    case binding(BindingAction<State>)
    case requests(id: FriendRequestCardLogic.State.ID, action: FriendRequestCardLogic.Action)
  }

  @Dependency(\.dismiss) var dismiss

  public var body: some Reducer<State, Action> {
    BindingReducer()
    Reduce<State, Action> { _, action in
      switch action {
      case .onTask:
        return .none

      case .closeButtonTapped:
        return .run { _ in
          await dismiss()
        }

      case .binding:
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

public struct FriendsOfFriendsView: View {
  let store: StoreOf<FriendsOfFriendsLogic>

  public init(store: StoreOf<FriendsOfFriendsLogic>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      VStack(spacing: 0) {
        SearchField(text: viewStore.$searchQuery)
        Divider()
        ScrollView {
          LazyVStack(spacing: 0) {
            ForEachStore(
              store.scope(state: \.requests, action: FriendsOfFriendsLogic.Action.requests),
              content: FriendRequestCardView.init(store:)
            )
          }
        }
      }
      .navigationTitle(Text("Friends of Friends", bundle: .module))
      .navigationBarTitleDisplayMode(.inline)
      .task { await viewStore.send(.onTask).finish() }
      .toolbar {
        Button {
          viewStore.send(.closeButtonTapped)
        } label: {
          Image(systemName: "xmark")
            .foregroundColor(.secondary)
        }
      }
    }
  }
}

struct FriendsOfFriendsViewPreviews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      FriendsOfFriendsView(
        store: .init(
          initialState: FriendsOfFriendsLogic.State(),
          reducer: { FriendsOfFriendsLogic() }
        )
      )
    }
  }
}
