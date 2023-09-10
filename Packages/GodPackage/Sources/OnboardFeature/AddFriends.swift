import Colors
import ComposableArchitecture
import SwiftUI

public struct AddFriendsLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    public init() {}
  }

  public enum Action: Equatable {
    case onTask
    case nextButtonTapped
    case delegate(Delegate)

    public enum Delegate: Equatable {
      case nextScreen
    }
  }

  public var body: some Reducer<State, Action> {
    Reduce<State, Action> { _, action in
      switch action {
      case .onTask:
        return .none

      case .nextButtonTapped:
        return .run { send in
          await send(.delegate(.nextScreen))
        }
      case .delegate:
        return .none
      }
    }
  }
}

public struct AddFriendsView: View {
  let store: StoreOf<AddFriendsLogic>

  public init(store: StoreOf<AddFriendsLogic>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      List(0 ..< 100, id: \.self) { _ in
        HStack(alignment: .center, spacing: 16) {
          Color.red
            .frame(width: 40, height: 40)
            .clipShape(Circle())

          VStack(alignment: .leading) {
            Text("Kevin Ding")

            Text("1 mutual friend")
              .foregroundColor(Color.godTextSecondaryLight)
          }

          Spacer()

          Color.white
            .frame(width: 26, height: 26)
            .overlay(
              RoundedRectangle(cornerRadius: 26 / 2)
                .stroke(Color.godTextSecondaryLight, lineWidth: 2)
            )
        }
      }
      .listStyle(.plain)
      .background(Color.godService)
      .navigationTitle("Add Friends")
      .navigationBarTitleDisplayMode(.inline)
      .toolbarBackground(Color.godService, for: .navigationBar)
      .toolbarBackground(.visible, for: .navigationBar)
      .toolbarColorScheme(.dark, for: .navigationBar)
      .task { await viewStore.send(.onTask).finish() }
      .toolbar {
        Button("Next") {
          viewStore.send(.nextButtonTapped)
        }
        .bold()
        .foregroundColor(Color.white)
      }
    }
  }
}

struct AddFriendsViewPreviews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      AddFriendsView(
        store: .init(
          initialState: AddFriendsLogic.State(),
          reducer: { AddFriendsLogic() }
        )
      )
    }
  }
}
