import ComposableArchitecture
import SwiftUI

public struct AddReducer: ReducerProtocol {
  public init() {}

  public struct State: Equatable {
    @PresentationState var friendsOfFriends: FriendsOfFriendsReducer.State?
    @PresentationState var fromSchool: FromSchoolReducer.State?
    public init() {}
  }

  public enum Action: Equatable {
    case onTask
    case seeMoreFriendsOfFriendsButtonTapped
    case seeMoreFromSchoolButtonTapped
    case friendsOfFriends(PresentationAction<FriendsOfFriendsReducer.Action>)
    case fromSchool(PresentationAction<FromSchoolReducer.Action>)
  }

  public var body: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      switch action {
      case .onTask:
        return .none
        
      case .seeMoreFriendsOfFriendsButtonTapped:
        state.friendsOfFriends = .init()
        return .none
        
      case .seeMoreFromSchoolButtonTapped:
        state.fromSchool = .init()
        return .none
        
      case .friendsOfFriends:
        return .none
        
      case .fromSchool:
        return .none
      }
    }
    .ifLet(\.$friendsOfFriends, action: /Action.friendsOfFriends) {
      FriendsOfFriendsReducer()
    }
    .ifLet(\.$fromSchool, action: /Action.fromSchool) {
      FromSchoolReducer()
    }
  }
}

public struct AddView: View {
  let store: StoreOf<AddReducer>

  public init(store: StoreOf<AddReducer>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      List {
        TextField("Search...", text: .constant(""))
          .listRowSeparator(.hidden)

        Section("FRIENDS OF FRIENDS") {
          ForEach(0..<3, id: \.self) { _ in
            FriendAddCard()
          }
          
          Button("See 19 more") {
            viewStore.send(.seeMoreFriendsOfFriendsButtonTapped)
          }
          .buttonStyle(SeeMoreButtonStyle())
        }
        
        Section("FROM SCHOOL") {
          ForEach(0..<3, id: \.self) { _ in
            FriendAddCard()
          }

          Button("See 471 more") {
            viewStore.send(.seeMoreFromSchoolButtonTapped)
          }
          .buttonStyle(SeeMoreButtonStyle())
        }
      }
      .listStyle(.grouped)
      .navigationTitle("Add")
      .navigationBarTitleDisplayMode(.inline)
      .task { await viewStore.send(.onTask).finish() }
      .sheet(
        store: store.scope(
          state: \.$friendsOfFriends,
          action: AddReducer.Action.friendsOfFriends
        )
      ) { store in
        NavigationStack {
          FriendsOfFriendsView(store: store)
        }
      }
      .sheet(
        store: store.scope(
          state: \.$fromSchool,
          action: AddReducer.Action.fromSchool
        )
      ) { store in
        NavigationStack {
          FromSchoolView(store: store)
        }
        }
    }
  }
}

struct AddViewPreviews: PreviewProvider {
  static var previews: some View {
    AddView(
      store: .init(
        initialState: AddReducer.State(),
        reducer: AddReducer()
      )
    )
  }
}
