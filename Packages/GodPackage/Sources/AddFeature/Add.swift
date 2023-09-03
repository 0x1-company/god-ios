import ComposableArchitecture
import SwiftUI

public struct AddLogic: Reducer {
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
      case friendsOfFriends(FriendsOfFriendsLogic.State = .init())
      case fromSchool(FromSchoolLogic.State = .init())
    }

    public enum Action: Equatable {
      case friendsOfFriends(FriendsOfFriendsLogic.Action)
      case fromSchool(FromSchoolLogic.Action)
    }

    public var body: some Reducer<State, Action> {
      Scope(state: /State.friendsOfFriends, action: /Action.friendsOfFriends) {
        FriendsOfFriendsLogic()
      }
      Scope(state: /State.fromSchool, action: /Action.fromSchool) {
        FromSchoolLogic()
      }
    }
  }
}

public struct AddView: View {
  let store: StoreOf<AddLogic>

  public init(store: StoreOf<AddLogic>) {
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
              /AddLogic.Destination.State.friendsOfFriends,
              action: AddLogic.Destination.Action.friendsOfFriends
            ) { store in
              NavigationStack {
                FriendsOfFriendsView(store: store)
              }
            }
          case .fromSchool:
            CaseLet(
              /AddLogic.Destination.State.fromSchool,
              action: AddLogic.Destination.Action.fromSchool
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
        initialState: AddLogic.State(),
        reducer: { AddLogic() }
      )
    )
  }
}
