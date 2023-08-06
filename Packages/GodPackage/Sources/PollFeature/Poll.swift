import ComposableArchitecture
import SwiftUI

public struct PollReducer: Reducer {
  public init() {}

  public struct State: Equatable {
    var vote = VoteReducer.State()
    public init() {}
  }

  public enum Action: Equatable {
    case vote(VoteReducer.Action)
  }

  public var body: some Reducer<State, Action> {
    Scope(state: \.vote, action: /Action.vote) {
      VoteReducer()
    }
    Reduce { _, action in
      switch action {
      case .vote:
        return .none
      }
    }
  }
}

public struct PollView: View {
  let store: StoreOf<PollReducer>

  public init(store: StoreOf<PollReducer>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { _ in
      ZStack(alignment: .top) {
        VoteView(
          store: store.scope(
            state: \.vote,
            action: PollReducer.Action.vote
          )
        )
        Text("2 of 12")
          .foregroundColor(Color.white)
      }
    }
  }
}

struct PollViewPreviews: PreviewProvider {
  static var previews: some View {
    PollView(
      store: .init(
        initialState: PollReducer.State(),
        reducer: { PollReducer() }
      )
    )
  }
}
