import ComposableArchitecture
import SwiftUI

public struct FromSchoolPanelLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    var users: IdentifiedArrayOf<FriendRowCardLogic.State>
  }

  public enum Action: Equatable {
    case users(id: FriendRowCardLogic.State.ID, action: FriendRowCardLogic.Action)
    case cardButtonTapped(String)
    case delegate(Delegate)
    
    public enum Delegate: Equatable {
      case showExternalProfile(userId: String)
    }
  }

  public var body: some Reducer<State, Action> {
    Reduce<State, Action> { _, action in
      switch action {
      case .users:
        return .none
        
      case let .cardButtonTapped(userId):
        return .send(.delegate(.showExternalProfile(userId: userId)), animation: .default)
        
      case .delegate:
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
        ) { cardStore in
          WithViewStore(cardStore, observe: { $0 }) { viewStore in
            FriendRowCardView(store: cardStore)
              .onTapGesture {
                store.send(.cardButtonTapped(viewStore.id))
              }
          }
        }
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
