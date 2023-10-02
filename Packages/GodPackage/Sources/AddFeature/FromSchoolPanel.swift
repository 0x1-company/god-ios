import ComposableArchitecture
import SwiftUI

public struct FromSchoolPanelLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    var users: IdentifiedArrayOf<FriendRowCardLogic.State>
  }

  public enum Action: Equatable {
    case users(id: FriendRowCardLogic.State.ID, action: FriendRowCardLogic.Action)
  }

  public var body: some Reducer<State, Action> {
    Reduce<State, Action> { _, action in
      switch action {
      case .users:
        return .none
      }
    }
    .forEach(\.users, action: /Action.users) {
      FriendRowCardLogic()
    }
  }
}

public struct FromSchoolPanelView: View {
  let store: StoreOf<FromSchoolPanelLogic>

  public init(store: StoreOf<FromSchoolPanelLogic>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { _ in
      LazyVStack(spacing: 0) {
        FriendHeader(title: "FROM SCHOOL")

        ForEachStore(
          store.scope(state: \.users, action: FromSchoolPanelLogic.Action.users)
        ) {
          FriendRowCardView(store: $0)
        }

//        Button {} label: {
//          Text("See \(viewStore.users.count) more", bundle: .module)
//        }
//        .buttonStyle(SeeMoreButtonStyle())
      }
    }
  }
}

#Preview {
  FromSchoolPanelView(
    store: .init(
      initialState: FromSchoolPanelLogic.State(
        users: []
      ),
      reducer: { FromSchoolPanelLogic() }
    )
  )
}
