import ComposableArchitecture
import SwiftUI

public struct AddReducer: Reducer {
  public init() {}

  public struct State: Equatable {
    @PresentationState var destination: Destination.State?
    public init() {}
  }

  public enum Action: Equatable {
    case onTask
    case seeMoreFriendsOfFriendsButtonTapped
    case seeMoreFromSchoolButtonTapped
    case destination(PresentationAction<Destination.Action>)
  }

  public var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .onTask:
        return .none

      case .seeMoreFriendsOfFriendsButtonTapped:
        state.destination = .friendsOfFriends()
        return .none

      case .seeMoreFromSchoolButtonTapped:
        state.destination = .fromSchool()
        return .none

      case .destination:
        return .none
      }
    }
    .ifLet(\.$destination, action: /Action.destination) {
      Destination()
    }
  }

  public struct Destination: Reducer {
    public enum State: Equatable {
      case friendsOfFriends(FriendsOfFriendsReducer.State = .init())
      case fromSchool(FromSchoolReducer.State = .init())
    }

    public enum Action: Equatable {
      case friendsOfFriends(FriendsOfFriendsReducer.Action)
      case fromSchool(FromSchoolReducer.Action)
    }

    public var body: some Reducer<State, Action> {
      Scope(state: /State.friendsOfFriends, action: /Action.friendsOfFriends) {
        FriendsOfFriendsReducer()
      }
      Scope(state: /State.fromSchool, action: /Action.fromSchool) {
        FromSchoolReducer()
      }
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
          ForEach(0 ..< 3, id: \.self) { _ in
            FriendAddCard()
          }

          Button("See 19 more") {
            viewStore.send(.seeMoreFriendsOfFriendsButtonTapped)
          }
          .buttonStyle(SeeMoreButtonStyle())
        }

        Section("FROM SCHOOL") {
          ForEach(0 ..< 3, id: \.self) { _ in
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
        store: store.scope(state: \.$destination, action: { .destination($0) })
      ) { store in
        SwitchStore(store) {
          switch $0 {
          case .friendsOfFriends:
            CaseLet(
              /AddReducer.Destination.State.friendsOfFriends,
              action: AddReducer.Destination.Action.friendsOfFriends
            ) { store in
              NavigationStack {
                FriendsOfFriendsView(store: store)
              }
            }
          case .fromSchool:
            CaseLet(
              /AddReducer.Destination.State.fromSchool,
              action: AddReducer.Destination.Action.fromSchool
            ) { store in
              NavigationStack {
                FromSchoolView(store: store)
              }
            }
          }
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
        reducer: { AddReducer() }
      )
    )
  }
}
