import ComposableArchitecture
import SwiftUI

public struct PlayAgainLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    var countdown = "00:00"
    var until: Date
    public init(until: Date) {
      self.until = until
    }
  }

  public enum Action: Equatable {
    case onTask
    case timerTick
    case inviteFriendButtonTapped
  }

  @Dependency(\.date.now) var now
  @Dependency(\.continuousClock) var clock
  @Dependency(\.calendar) var calendar

  public var body: some Reducer<State, Action> {
    Reduce<State, Action> { state, action in
      switch action {
      case .onTask:
        return .run { send in
          await withTaskGroup(of: Void.self) { group in
            group.addTask {
              await startTimer(send: send)
            }
          }
        }
      case .timerTick:
        let difference = calendar.dateComponents([.minute, .second], from: now, to: state.until)
        let minute = difference.minute ?? 0
        let second = difference.second ?? 0
        state.countdown = "\(minute):\(second)"
        return .none

      case .inviteFriendButtonTapped:
        return .none
      }
    }
  }

  private func startTimer(send: Send<Action>) async {
    for await _ in clock.timer(interval: .seconds(1)) {
      await send(.timerTick)
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
        Text("Play Again", bundle: .module)
          .bold()
          .font(.largeTitle)

        Image(.locked)
          .rotationEffect(Angle(degrees: -10.0))

        Text("New Polls in \(viewStore.countdown)", bundle: .module)
          .bold()

        Text("OR", bundle: .module)
          .foregroundColor(.secondary)

        Text("Skip the wait", bundle: .module)
          .foregroundColor(.secondary)

        Button {
          viewStore.send(.inviteFriendButtonTapped)
        } label: {
          Text("Invite a friend", bundle: .module)
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
      .task { await viewStore.send(.onTask).finish() }
    }
  }
}

#Preview {
  PlayAgainView(
    store: .init(
      initialState: PlayAgainLogic.State(
        until: Date.now.addingTimeInterval(3600)
      ),
      reducer: { PlayAgainLogic() }
    )
  )
}
