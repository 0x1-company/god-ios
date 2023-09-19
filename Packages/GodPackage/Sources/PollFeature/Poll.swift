import ComposableArchitecture
import God
import SwiftUI

public struct PollLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    var poll: God.CurrentPollQuery.Data.CurrentPoll.Poll
    public init(
      poll: God.CurrentPollQuery.Data.CurrentPoll.Poll
    ) {
      self.poll = poll
    }
  }

  public enum Action: Equatable {
    case onTask
  }

  public var body: some Reducer<State, Action> {
    Reduce<State, Action> { _, action in
      switch action {
      case .onTask:
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
    WithViewStore(store, observe: { $0 }) { viewStore in
      List {
        Text("Poll", bundle: .module)
      }
      .navigationTitle("Poll")
      .navigationBarTitleDisplayMode(.inline)
      .task { await viewStore.send(.onTask).finish() }
    }
  }
}
