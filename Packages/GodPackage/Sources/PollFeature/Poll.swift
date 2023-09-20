import ComposableArchitecture
import God
import GodClient
import SwiftUI

public struct PollLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    var pollId: String
    var pollQuestions: IdentifiedArrayOf<PollQuestionLogic.State>
    var currentId: String
    var currentPosition = 1

    public init(
      poll: God.CurrentPollQuery.Data.CurrentPoll.Poll
    ) {
      pollId = poll.id
      pollQuestions = .init(
        uniqueElements: poll.pollQuestions.map(PollQuestionLogic.State.init)
      )
      currentId = pollQuestions[0].id
    }
  }

  public enum Action: Equatable {
    case onTask
    case pollQuestions(id: PollQuestionLogic.State.ID, action: PollQuestionLogic.Action)
    case createVoteResponse(TaskResult<God.CreateVoteMutation.Data>)
    case completePollResponse(TaskResult<God.CompletePollMutation.Data>)
    case delegate(Delegate)

    public enum Delegate: Equatable {
      case finish(earnedCoinAmount: Int)
    }
  }

  @Dependency(\.godClient.createVote) var createVote
  @Dependency(\.godClient.completePoll) var completePoll

  public var body: some Reducer<State, Action> {
    Reduce<State, Action> { state, action in
      switch action {
      case .onTask:
        return .none

      case let .pollQuestions(_, .delegate(.vote(input))):
        return .run { send in
          await send(.createVoteResponse(TaskResult {
            try await createVote(input)
          }))
        }

      case let .pollQuestions(id, .delegate(.nextPollQuestion)):
        guard let index = state.pollQuestions.index(id: id) else { return .none }
        let afterIndex = state.pollQuestions.index(after: index)

        guard afterIndex < state.pollQuestions.count else {
          return .run { [pollId = state.pollId] send in
            await completePollRequest(pollId: pollId, send: send)
          }
        }
        let element = state.pollQuestions.elements[afterIndex]
        state.currentId = element.id
        state.currentPosition = afterIndex + 1
        return .none

      case .pollQuestions:
        return .none

      case let .createVoteResponse(.success(data)):
        print(data)
        return .none

      case .createVoteResponse(.failure):
        return .none

      case let .completePollResponse(.success(data)):
        let earnedCoinAmount = data.completePoll.earnedCoinAmount
        return .send(.delegate(.finish(earnedCoinAmount: earnedCoinAmount)), animation: .default)

      case .completePollResponse(.failure):
        return .none

      case .delegate:
        return .none
      }
    }
    .forEach(\.pollQuestions, action: /Action.pollQuestions) {
      PollQuestionLogic()
    }
  }

  func completePollRequest(pollId: String, send: Send<Action>) async {
    let input = God.CompletePollInput(pollId: pollId)
    await send(.completePollResponse(TaskResult {
      try await completePoll(input)
    }))
  }
}

public struct PollView: View {
  let store: StoreOf<PollLogic>

  public init(store: StoreOf<PollLogic>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      ZStack(alignment: .top) {
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
            withAnimation {
              proxy.scrollTo(newValue)
            }
          }
        }
        .ignoresSafeArea()

        Text("\(viewStore.currentPosition) of 12")
          .foregroundStyle(.white)
      }
      .task { await viewStore.send(.onTask).finish() }
    }
  }
}
