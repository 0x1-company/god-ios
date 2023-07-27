import ComposableArchitecture
import SwiftUI

public struct QuestionReducer: ReducerProtocol {
  public init() {}

  public struct State: Equatable {
    public init() {}
  }

  public enum Action: Equatable {
    case onTask
  }

  public var body: some ReducerProtocol<State, Action> {
    Reduce { _, action in
      switch action {
        case .onTask:
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
    WithViewStore(store, observe: { $0 }) { viewStore in
      List {
        Text("Question")
      }
      .navigationTitle("Question")
      .navigationBarTitleDisplayMode(.inline)
      .task { await viewStore.send(.onTask).finish() }
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