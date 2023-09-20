import ButtonStyles
import Colors
import ComposableArchitecture
import FeedbackGeneratorClient
import God
import LabeledButton
import SwiftUI

public struct PollQuestionLogic: Reducer {
  public init() {}

  public struct State: Equatable, Identifiable {
    var pollQuestion: God.CurrentPollQuery.Data.CurrentPoll.Poll.PollQuestion
    public var id: String {
      pollQuestion.id
    }

    @PresentationState var alert: AlertState<Action.Alert>?
    var isAnswered = false
    var currentChoiceGroup: God.CurrentPollQuery.Data.CurrentPoll.Poll.PollQuestion.ChoiceGroup
    var currentStep = Step.first

    public init(pollQuestion: God.CurrentPollQuery.Data.CurrentPoll.Poll.PollQuestion) {
      self.pollQuestion = pollQuestion
      currentChoiceGroup = pollQuestion.choiceGroups[currentStep.rawValue]
    }
    
    public enum Step: Int {
      case first
      case second
      case thaad
    }
  }

  public enum Action: Equatable {
    case onTask
    case voteButtonTapped(votedUserId: String)
    case shuffleButtonTapped
    case skipButtonTapped
    case continueButtonTapped
    case alert(PresentationAction<Alert>)
    case delegate(Delegate)

    public enum Alert: Equatable {
      case confirmOkay
    }

    public enum Delegate: Equatable {
      case vote(God.CreateVoteInput)
      case nextPollQuestion
    }
  }

  @Dependency(\.feedbackGenerator) var feedbackGenerator

  public var body: some Reducer<State, Action> {
    Reduce<State, Action> { state, action in
      switch action {
      case .onTask:
        return .none

      case let .voteButtonTapped(votedUserId):
        state.isAnswered = true
        let input = God.CreateVoteInput(
          choiceGroup: God.ChoiceGroupInput(
            choices: state.currentChoiceGroup.choices.map {
              God.ChoiceInput(text: $0.text, userId: $0.userId)
            },
            signature: God.SignatureInput(
              digest: state.currentChoiceGroup.signature.digest
            )
          ),
          pollQuestionId: state.pollQuestion.id,
          votedUserId: votedUserId
        )
        return .send(.delegate(.vote(input)))

      case .shuffleButtonTapped:
        guard let nextStep = State.Step(rawValue: state.currentStep.rawValue + 1)
        else { return .none }

        state.currentStep = nextStep
        state.currentChoiceGroup = state.pollQuestion.choiceGroups[nextStep.rawValue]

        return .run { _ in
          await feedbackGenerator.mediumImpact()
        }
      case .skipButtonTapped:
        return .run { _ in
          await feedbackGenerator.mediumImpact()
        }
      case .continueButtonTapped:
        state.isAnswered = false
        return .run { send in
          await feedbackGenerator.mediumImpact()
          await send(.delegate(.nextPollQuestion))
        }
      case .alert:
        state.alert = AlertState {
          TextState("Woah, slow down!🐎")
        } actions: {
          ButtonState(action: .confirmOkay) {
            TextState("OK")
          }
        } message: {
          TextState("You're voting too fast")
        }
        return .none
      case .delegate:
        return .none
      }
    }
  }
}

public struct PollQuestionView: View {
  let store: StoreOf<PollQuestionLogic>

  public init(store: StoreOf<PollQuestionLogic>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      VStack(spacing: 0) {
        Spacer()

        Image(.books)
          .resizable()
          .scaledToFit()
          .frame(height: 140)

        Text(verbatim: viewStore.pollQuestion.question.text.ja)
          .font(.title2)
          .foregroundColor(.white)

        Spacer()

        LazyVGrid(
          columns: Array(repeating: GridItem(spacing: 16), count: 2),
          spacing: 16
        ) {
          ForEach(viewStore.currentChoiceGroup.choices, id: \.self) { choice in
            AnswerButton(
              choice.text,
              progress: viewStore.isAnswered ? Double.random(in: 0.1 ..< 0.9) : 0.0
            ) {
              viewStore.send(.voteButtonTapped(votedUserId: choice.userId))
            }
            .disabled(viewStore.isAnswered)
          }
        }

        ZStack {
          if viewStore.isAnswered {
            Button {
              viewStore.send(.continueButtonTapped)
            } label: {
              Text("Tap to continue", bundle: .module)
            }
          } else {
            HStack(spacing: 0) {
              LabeledButton(
                String(localized: "Shuffle", bundle: .module),
                systemImage: "shuffle"
              ) {
                viewStore.send(.shuffleButtonTapped)
              }
              LabeledButton(
                String(localized: "Skip", bundle: .module),
                systemImage: "forward.fill"
              ) {
                viewStore.send(.skipButtonTapped)
              }
            }
            .buttonStyle(HoldDownButtonStyle())
          }
        }
        .frame(height: 50)
        .animation(.default, value: viewStore.isAnswered)
        .foregroundColor(.white)
        .padding(.vertical, 64)
      }
      .padding(.horizontal, 36)
      .background(Color.godGreen)
      .task { await viewStore.send(.onTask).finish() }
      .alert(store: store.scope(state: \.$alert, action: { .alert($0) }))
      .frame(height: UIScreen.main.bounds.height)
    }
  }
}
