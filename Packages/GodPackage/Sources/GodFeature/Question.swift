import ComposableArchitecture
import SwiftUI

public struct QuestionReducer: Reducer {
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

public struct QuestionView: View {
  let store: StoreOf<QuestionReducer>

  public init(store: StoreOf<QuestionReducer>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { _ in
      ZStack(alignment: .top) {
        VoteView(
          store: store.scope(
            state: \.vote,
            action: QuestionReducer.Action.vote
          )
        )
        Text("2 of 12")
          .foregroundColor(Color.white)
      }
    }
  }
}

struct QuestionViewPreviews: PreviewProvider {
  static var previews: some View {
    QuestionView(
      store: .init(
        initialState: QuestionReducer.State(),
        reducer: QuestionReducer()
      )
    )
  }
}
