import ButtonStyles
import Colors
import ComposableArchitecture
import God
import GodClient
import SwiftUI

public struct FriendRowCardLogic: Reducer {
  public init() {}

  public struct State: Equatable, Identifiable {
    public var id: String
    var displayName: String
    var description: String

    public init(id: String, displayName: String, description: String) {
      self.id = id
      self.displayName = displayName
      self.description = description
    }
  }

  public enum Action: Equatable {
    case onTask
    case hideButtonTapped
    case addButtonTapped
  }

  @Dependency(\.godClient) var godClient

  public var body: some Reducer<State, Action> {
    Reduce<State, Action> { _, action in
      switch action {
      case .onTask:
        return .none

      case .hideButtonTapped:
        return .none

      case .addButtonTapped:
        return .none
      }
    }
  }
}

public struct FriendRowCardView: View {
  let store: StoreOf<FriendRowCardLogic>

  public init(store: StoreOf<FriendRowCardLogic>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      HStack(alignment: .center, spacing: 16) {
        Color.red
          .frame(width: 40, height: 40)
          .clipShape(Circle())

        VStack(alignment: .leading) {
          Text(verbatim: viewStore.displayName)

          Text(verbatim: viewStore.description)
            .foregroundStyle(.secondary)
        }

        HStack(spacing: 0) {
          Button {
            viewStore.send(.hideButtonTapped)
          } label: {
            Text("HIDE", bundle: .module)
              .frame(width: 80, height: 34)
              .foregroundStyle(.secondary)
          }

          Button {
            viewStore.send(.addButtonTapped)
          } label: {
            Text("ADD", bundle: .module)
              .frame(width: 80, height: 34)
              .foregroundColor(Color.white)
              .background(Color.orange)
              .clipShape(Capsule())
          }
        }
        .buttonStyle(HoldDownButtonStyle())
      }
      .task { await viewStore.send(.onTask).finish() }
    }
  }
}

#Preview {
  FriendRowCardView(
    store: .init(
      initialState: FriendRowCardLogic.State(
        id: "1",
        displayName: "Taro Tanaka",
        description: "Grade 9"
      ),
      reducer: { FriendRowCardLogic() }
    )
  )
}
