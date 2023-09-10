import ButtonStyles
import Colors
import ComposableArchitecture
import SwiftUI

public struct FriendRequestCardLogic: Reducer {
  public init() {}

  public struct State: Equatable, Identifiable {
    public var id = UUID()
    public init() {}
  }

  public enum Action: Equatable {
    case onTask
    case addButtonTapped
    case hideButtonTapped
  }

  public var body: some ReducerOf<Self> {
    Reduce<State, Action> { _, action in
      switch action {
      case .onTask:
        return .none

      case .addButtonTapped:
        return .none

      case .hideButtonTapped:
        return .none
      }
    }
  }
}

public struct FriendRequestCardView: View {
  let store: StoreOf<FriendRequestCardLogic>

  public init(store: StoreOf<FriendRequestCardLogic>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      HStack(alignment: .center, spacing: 16) {
        Color.red
          .frame(width: 40, height: 40)
          .clipShape(Circle())

        VStack(alignment: .leading) {
          Text("Tomoki Tsukiyama")

          Text("1 mutual friend")
            .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)

        HStack(spacing: 0) {
          Button {} label: {
            Text("HIDE")
              .frame(width: 80, height: 33)
              .foregroundColor(.secondary)
          }
          .buttonStyle(HoldDownButtonStyle())

          Button {} label: {
            Text("ADD")
              .frame(width: 80, height: 33)
              .foregroundColor(Color.white)
              .background(Color.godService)
              .clipShape(Capsule())
          }
          .buttonStyle(HoldDownButtonStyle())
        }
      }
      .frame(height: 76)
      .padding(.horizontal, 16)
      .task { await viewStore.send(.onTask).finish() }
    }
  }
}

struct FriendRequestCardViewPreviews: PreviewProvider {
  static var previews: some View {
    FriendRequestCardView(
      store: .init(
        initialState: FriendRequestCardLogic.State(),
        reducer: { FriendRequestCardLogic() }
      )
    )
  }
}
