import Colors
import ComposableArchitecture
import SwiftUI

public struct AddFriendsReducer: Reducer {
  public init() {}

  public struct State: Equatable {
    public init() {}
  }

  public enum Action: Equatable {
    case onTask
    case nextButtonTapped
    case delegate(Delegate)

    public enum Delegate: Equatable {
      case nextHowItWorks
    }
  }

  public var body: some ReducerOf<Self> {
    Reduce { _, action in
      switch action {
      case .onTask:
        return .none

      case .nextButtonTapped:
        return .run { send in
          await send(.delegate(.nextHowItWorks))
        }
      case .delegate:
        return .none
      }
    }
  }
}

public struct AddFriendsView: View {
  let store: StoreOf<AddFriendsReducer>

  public init(store: StoreOf<AddFriendsReducer>) {
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
              .foregroundColor(Color.god.textSecondaryLight)
          }

          Spacer()

          Color.white
            .frame(width: 26, height: 26)
            .overlay(
              RoundedRectangle(cornerRadius: 26 / 2)
                .stroke(Color.god.textSecondaryLight, lineWidth: 2)
            )
        }
      }
      .listStyle(.plain)
      .background(Color.god.service)
      .navigationTitle("Add Friends")
      .navigationBarTitleDisplayMode(.inline)
      .toolbarBackground(Color.god.service, for: .navigationBar)
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
          initialState: AddFriendsReducer.State(),
          reducer: { AddFriendsReducer() }
        )
      )
    }
  }
}
