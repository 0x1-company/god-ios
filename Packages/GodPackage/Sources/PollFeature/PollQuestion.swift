import ButtonStyles
import Colors
import ComposableArchitecture
import FeedbackGeneratorClient
import LabeledButton
import SwiftUI
import God

public struct PollQuestionLogic: Reducer {
  public init() {}

  public struct State: Equatable, Identifiable {
    public enum Step: Int {
      case first
      case second
      case thaad
    }

    public var id: String {
      pollQuestion.id
    }
    var pollQuestion: God.CurrentPollQuery.Data.CurrentPoll.Poll.PollQuestion
    
    @PresentationState var alert: AlertState<Action.Alert>?
    var isAnswered = false
    var choices: [God.CurrentPollQuery.Data.CurrentPoll.Poll.PollQuestion.ChoiceGroup.Choice] = []
    var currentStep = Step.first

    public init(pollQuestion: God.CurrentPollQuery.Data.CurrentPoll.Poll.PollQuestion) {
      self.pollQuestion = pollQuestion
      self.choices = pollQuestion.choiceGroups[currentStep.rawValue].choices
    }
  }

  public enum Action: Equatable {
    case onTask
    case answerButtonTapped
    case shuffleButtonTapped
    case skipButtonTapped
    case continueButtonTapped
    case alert(PresentationAction<Alert>)
    case delegate(Delegate)

    public enum Alert: Equatable {
      case confirmOkay
    }
    
    public enum Delegate: Equatable {
      case nextPollQuestion
    }
  }

  @Dependency(\.feedbackGenerator) var feedbackGenerator

  public var body: some Reducer<State, Action> {
    Reduce<State, Action> { state, action in
      switch action {
      case .onTask:
        return .none

      case .answerButtonTapped:
        state.isAnswered = true
        return .none

      case .shuffleButtonTapped:
        guard let nextStep = State.Step(rawValue: state.currentStep.rawValue + 1)
        else { return .none }
        state.currentStep = nextStep
        state.choices = state.pollQuestion.choiceGroups[nextStep.rawValue].choices
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
          await send(.delegate(.nextPollQuestion), animation: .default)
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
          ForEach(viewStore.choices, id: \.self) { choice in
            AnswerButton(
              choice.text,
              progress: viewStore.isAnswered ? Double.random(in: 0.1 ..< 0.9) : 0.0
            ) {
              viewStore.send(.answerButtonTapped, animation: .default)
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
