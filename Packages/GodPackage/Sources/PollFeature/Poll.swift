import ComposableArchitecture
import God
import SwiftUI

public struct PollLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    var pollQuestions: IdentifiedArrayOf<PollQuestionLogic.State>
    var currentId: String

    public init(
      poll: God.CurrentPollQuery.Data.CurrentPoll.Poll
    ) {
      pollQuestions = .init(
        uniqueElements: poll.pollQuestions.map(PollQuestionLogic.State.init)
      )
      currentId = pollQuestions[0].id
    }
  }

  public enum Action: Equatable {
    case onTask
    case pollQuestions(id: PollQuestionLogic.State.ID, action: PollQuestionLogic.Action)
    case delegate(Delegate)

    public enum Delegate: Equatable {
      case finish
    }
  }

  public var body: some Reducer<State, Action> {
    Reduce<State, Action> { state, action in
      switch action {
      case .onTask:
        return .none

      case let .pollQuestions(id, .delegate(.nextPollQuestion)):
        guard let index = state.pollQuestions.index(id: id) else { return .none }
        let afterIndex = state.pollQuestions.index(after: index)
        guard afterIndex < state.pollQuestions.count else {
          return .send(.delegate(.finish), animation: .default)
        }
        let element = state.pollQuestions.elements[afterIndex]
        state.currentId = element.id
        return .none

      case .pollQuestions:
        return .none

      case .delegate:
        return .none
      }
    }
    .forEach(\.pollQuestions, action: /Action.pollQuestions) {
      PollQuestionLogic()
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
      ScrollViewReader { proxy in
        ScrollView(showsIndicators: false) {
          LazyVStack(spacing: 0) {
            ForEachStore(
              store.scope(state: \.pollQuestions, action: PollLogic.Action.pollQuestions)
            ) { store in
              WithViewStore(store, observe: \.id) { id in
                PollQuestionView(store: store)
                  .id(id.state)
              }
            }
          }
        }
        .scrollDisabled(true)
        .onChange(of: viewStore.currentId) { newValue in
          proxy.scrollTo(newValue)
        }
      }
      .ignoresSafeArea()
      .task { await viewStore.send(.onTask).finish() }
    }
  }
}
