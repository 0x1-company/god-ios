import ComposableArchitecture
import SwiftUI

public struct PollLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    var vote = VoteLogic.State()
    public init() {}
  }

  public enum Action: Equatable {
    case vote(VoteLogic.Action)
  }

  public var body: some Reducer<State, Action> {
    Scope(state: \.vote, action: /Action.vote) {
      VoteLogic()
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
  let store: StoreOf<PollLogic>

  public init(store: StoreOf<PollLogic>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { _ in
      ZStack(alignment: .top) {
        VoteView(
          store: store.scope(
            state: \.vote,
            action: PollLogic.Action.vote
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
        initialState: PollLogic.State(),
        reducer: { PollLogic() }
      )
    )
  }
}
