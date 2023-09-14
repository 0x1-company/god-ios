import ComposableArchitecture
import SwiftUI

public struct PlayAgainLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    public init() {}
  }

  public enum Action: Equatable {
    case inviteFriendButtonTapped
  }

  public var body: some Reducer<State, Action> {
    Reduce<State, Action> { _, action in
      switch action {
      case .inviteFriendButtonTapped:
        return .none
      }
    }
  }
}

public struct PlayAgainView: View {
  let store: StoreOf<PlayAgainLogic>

  public init(store: StoreOf<PlayAgainLogic>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      VStack(spacing: 44) {
        Text("Play Again")
          .bold()
          .font(.largeTitle)

        Image(.locked)
          .rotationEffect(Angle(degrees: -10.0))

        Text("New Polls in 54:36")
          .bold()

        Text("OR")
          .foregroundColor(.secondary)

        Text("Skip the wait")
          .foregroundColor(.secondary)

        Button {
          viewStore.send(.inviteFriendButtonTapped)
        } label: {
          Text("Invite a friend")
            .bold()
            .font(.title2)
            .frame(height: 54)
            .frame(maxWidth: .infinity)
            .foregroundColor(Color.black)
        }
        .background(Color.white)
        .clipShape(Capsule())
        .shadow(color: .black.opacity(0.2), radius: 25)
        .padding(.horizontal, 65)
      }
    }
  }
}

struct PlayAgainViewPreviews: PreviewProvider {
  static var previews: some View {
    PlayAgainView(
      store: .init(
        initialState: PlayAgainLogic.State(),
        reducer: { PlayAgainLogic() }
      )
    )
  }
}
