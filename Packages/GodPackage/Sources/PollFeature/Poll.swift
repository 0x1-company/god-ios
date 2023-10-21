import ComposableArchitecture
import God
import GodClient
import SwiftUI
import FeedbackGeneratorClient

public struct PollLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    let poll: God.CurrentPollQuery.Data.CurrentPoll.Poll
    var skipAvailableCount: Int
    var pollQuestions: IdentifiedArrayOf<PollQuestionLogic.State>
    var currentPollQuestionId: String
    var currentPollQuestionPosition = 1
    @PresentationState var alert: AlertState<Action.Alert>?

    public init(
      poll: God.CurrentPollQuery.Data.CurrentPoll.Poll
    ) {
      self.poll = poll
      skipAvailableCount = poll.skipAvailableCount
      pollQuestions = .init(
        uniqueElements: poll.pollQuestions.enumerated().map {
          PollQuestionLogic.State(
            backgroundColor: Color("question-background-\($0.offset + 1)", bundle: .module),
            pollQuestion: $0.element
          )
        }
      )
      currentPollQuestionId = pollQuestions[0].id
    }
  }

  public enum Action: Equatable {
    case onTask
    case pollQuestions(id: PollQuestionLogic.State.ID, action: PollQuestionLogic.Action)
    case createVoteResponse(TaskResult<God.CreateVoteMutation.Data>)
    case completePollResponse(TaskResult<God.CompletePollMutation.Data>)
    case alert(PresentationAction<Alert>)
    case delegate(Delegate)
    
    public enum Alert: Equatable {
      case confirmOkay
    }

    public enum Delegate: Equatable {
      case voted
      case finish(earnedCoinAmount: Int)
    }
  }

  @Dependency(\.godClient.createVote) var createVote
  @Dependency(\.godClient.completePoll) var completePoll
  @Dependency(\.feedbackGenerator) var feedbackGenerator

  public var body: some Reducer<State, Action> {
    Reduce<State, Action> { state, action in
      switch action {
      case .onTask:
        return .none

      case let .pollQuestions(_, .delegate(.vote(input))):
        return .run { send in
          await send(.delegate(.voted))
          await send(.createVoteResponse(TaskResult {
            try await createVote(input)
          }))
        }

      case let .pollQuestions(id, .delegate(.nextPollQuestion)):
        return nextPollQuestion(state: &state, id: id)
        
      case let .pollQuestions(id, .delegate(.skip)) where state.skipAvailableCount > 0:
        state.skipAvailableCount -= 1
        return nextPollQuestion(state: &state, id: id)
        
      case .pollQuestions(_, .delegate(.skip)):
        state.alert = AlertState {
          TextState("You cannot skip questions", bundle: .module)
        } actions: {
          ButtonState {
            TextState("OK", bundle: .module)
          }
        }
        return .run { _ in
          await feedbackGenerator.notificationOccurred(.error)
        }

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
        state.alert = AlertState {
          TextState("You cannot skip all questions.", bundle: .module)
        } actions: {
          ButtonState(action: .send(.confirmOkay, animation: .default)) {
            TextState("OK", bundle: .module)
          }
        } message: {
          TextState("Please start over from the beginning.", bundle: .module)
        }
        return .none
        
      case .alert(.presented(.confirmOkay)):
        state.alert = nil
        let element = state.pollQuestions.elements[0]
        state.currentPollQuestionId = element.id
        state.currentPollQuestionPosition = 1
        return .none
        
      case .alert(.dismiss):
        state.alert = nil
        return .none
        
      case .alert:
        return .none

      case .delegate:
        return .none
      }
    }
    .forEach(\.pollQuestions, action: /Action.pollQuestions) {
      PollQuestionLogic()
    }
  }
  
  func nextPollQuestion(state: inout State, id: PollQuestionLogic.State.ID) -> Effect<Action> {
    guard let index = state.pollQuestions.index(id: id) else { return .none }
    let afterIndex = state.pollQuestions.index(after: index)

    guard afterIndex < state.pollQuestions.count else {
      return .run { [pollId = state.poll.id] send in
        await completePollRequest(pollId: pollId, send: send)
      }
    }
    let element = state.pollQuestions.elements[afterIndex]
    state.currentPollQuestionId = element.id
    state.currentPollQuestionPosition = afterIndex + 1
    return .none
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
          .onChange(of: viewStore.currentPollQuestionId) { newValue in
            withAnimation {
              proxy.scrollTo(newValue)
            }
          }
        }
        .ignoresSafeArea()

        VStack(spacing: 18) {
          ProgressView(
            value: Double(viewStore.currentPollQuestionPosition),
            total: Double(viewStore.pollQuestions.count)
          )
          .tint(Color.white)

          Text("\(viewStore.currentPollQuestionPosition) of \(viewStore.pollQuestions.count)", bundle: .module)
            .bold()
            .foregroundStyle(.white)
        }
        .padding(.top, 52)
      }
      .task { await viewStore.send(.onTask).finish() }
      .alert(store: store.scope(state: \.$alert, action: PollLogic.Action.alert))
    }
  }
}
