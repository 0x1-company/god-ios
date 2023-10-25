import AnalyticsClient
import CachedAsyncImage
import ComposableArchitecture
import FeedbackGeneratorClient
import God
import LabeledButton
import Styleguide
import SwiftUI

public struct PollQuestionLogic: Reducer {
  public init() {}

  public struct State: Equatable, Identifiable {
    public var id: String
    var backgroundColor: Color
    var question: God.CurrentPollQuery.Data.CurrentPoll.Poll.PollQuestion.Question
    var choiceGroups: [God.CurrentPollQuery.Data.CurrentPoll.Poll.PollQuestion.ChoiceGroup]

    @PresentationState var alert: AlertState<Action.Alert>?
    var voteChoices: [String: Double] = [:]
    var currentIndex = 0
    var isPollAvailable = false

    var currentChoiceGroup: God.CurrentPollQuery.Data.CurrentPoll.Poll.PollQuestion.ChoiceGroup {
      choiceGroups[currentIndex]
    }

    public init(
      backgroundColor: Color,
      pollQuestion: God.CurrentPollQuery.Data.CurrentPoll.Poll.PollQuestion
    ) {
      id = pollQuestion.id
      question = pollQuestion.question
      choiceGroups = pollQuestion.choiceGroups
      self.backgroundColor = backgroundColor
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
    case pollAvailable
    case alert(PresentationAction<Alert>)
    case delegate(Delegate)

    public enum Alert: Equatable {
      case confirmOkay
    }

    public enum Delegate: Equatable {
      case vote(God.CreateVoteInput)
      case nextPollQuestion
      case skip
    }
  }

  @Dependency(\.mainQueue) var mainQueue
  @Dependency(\.analytics) var analytics
  @Dependency(\.feedbackGenerator) var feedbackGenerator

  public var body: some Reducer<State, Action> {
    Reduce<State, Action> { state, action in
      switch action {
      case .onTask:
        return .run { send in
          await sleepPollAvailable(send: send)
        }

      case let .voteButtonTapped(votedUserId) where !state.isPollAvailable:
        analytics.buttonClick(name: .voteSlowDown, parameters: [
          "voted_user_id": votedUserId,
          "question_id": state.question.id,
          "question_text": state.question.text.ja,
        ])
        state.alert = AlertState {
          TextState("Woah, slow down!🐎", bundle: .module)
        } actions: {
          ButtonState(action: .confirmOkay) {
            TextState("OK", bundle: .module)
          }
        } message: {
          TextState("You're voting too fast", bundle: .module)
        }
        return .run { _ in
          await feedbackGenerator.notificationOccurred(.error)
        }

      case let .voteButtonTapped(votedUserId) where state.isPollAvailable:
        var voteChoices: [God.ID: Double] = [:]
        state.currentChoiceGroup.choices.forEach { choice in
          voteChoices[choice.userId] = choice.userId == votedUserId ? Double.random(in: 0.4 ..< 0.6) : Double.random(in: 0.01 ..< 0.4)
        }
        state.voteChoices = voteChoices
        let input = God.CreateVoteInput(
          choiceGroup: God.ChoiceGroupInput(
            choices: state.choiceGroups[state.currentIndex].choices.map {
              God.ChoiceInput(text: $0.text, userId: $0.userId)
            },
            signature: God.SignatureInput(
              digest: state.choiceGroups[state.currentIndex].signature.digest
            )
          ),
          pollQuestionId: state.id,
          votedUserId: votedUserId
        )
        analytics.logEvent("vote", [
          "voted_user_id": votedUserId,
          "question_id": state.question.id,
          "question": state.question.text.ja,
        ])
        return .run { send in
          await feedbackGenerator.impactOccurred()
          await send(.delegate(.vote(input)))
        }

      case .shuffleButtonTapped:
        let maxPageIndex = state.choiceGroups.count - 1
        let nextIndex = state.currentIndex + 1
        analytics.buttonClick(name: .shuffle, parameters: [
          "question_id": state.question.id,
          "question_text": state.question.text.ja,
          "current_index": state.currentIndex,
          "next_index": nextIndex,
        ])
        guard nextIndex <= maxPageIndex else { return .none }
        state.currentIndex = nextIndex
        return .run { _ in
          await feedbackGenerator.impactOccurred()
        }
      case .skipButtonTapped:
        analytics.buttonClick(name: .skip, parameters: [
          "question_id": state.question.id,
          "question_text": state.question.text.ja,
        ])
        return .run { send in
          await feedbackGenerator.impactOccurred()
          await send(.delegate(.skip), animation: .default)
        }
      case .continueButtonTapped:
        return .run { send in
          await feedbackGenerator.impactOccurred()
          await send(.delegate(.nextPollQuestion), animation: .default)
        }
      case .pollAvailable:
        state.isPollAvailable = true
        return .none

      case .alert(.presented(.confirmOkay)):
        state.alert = nil
        return .none

      default:
        return .none
      }
    }
  }

  func sleepPollAvailable(send: Send<Action>) async {
    do {
      try await mainQueue.sleep(for: .seconds(1))
      await send(.pollAvailable)
    } catch {}
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

        CachedAsyncImage(
          url: URL(string: viewStore.question.imageURL),
          content: { image in
            image
              .resizable()
              .aspectRatio(contentMode: .fit)
              .frame(height: 140)
              .clipped()
          },
          placeholder: {
            ProgressView()
              .progressViewStyle(.circular)
          }
        )

        Spacer().frame(height: 24)

        Text(viewStore.question.text.ja)
          .foregroundStyle(.white)
          .multilineTextAlignment(.center)
          .font(.system(.title2, design: .rounded, weight: .bold))

        Spacer()

        LazyVGrid(
          columns: Array(repeating: GridItem(spacing: 16), count: 2),
          spacing: 16
        ) {
          ForEach(viewStore.currentChoiceGroup.choices, id: \.self) { choice in
            AnswerButton(
              choice.text,
              progress: viewStore.voteChoices[choice.userId] ?? 0.0,
              color: viewStore.backgroundColor
            ) {
              viewStore.send(.voteButtonTapped(votedUserId: choice.userId))
            }
            .disabled(!viewStore.voteChoices.isEmpty)
          }
        }

        ZStack {
          if !viewStore.voteChoices.isEmpty {
            Text("Tap to continue", bundle: .module)
          } else {
            HStack(spacing: 0) {
              LabeledButton(
                String(localized: "Shuffle", bundle: .module),
                systemImage: "shuffle"
              ) {
                store.send(.shuffleButtonTapped, animation: .default)
              }
              LabeledButton(
                String(localized: "Skip", bundle: .module),
                systemImage: "forward.fill"
              ) {
                store.send(.skipButtonTapped, animation: .default)
              }
            }
            .buttonStyle(HoldDownButtonStyle())
          }
        }
        .frame(height: 50)
        .foregroundStyle(.white)
        .padding(.vertical, 64)
        .font(.system(.body, design: .rounded, weight: .bold))
        .animation(.default, value: !viewStore.voteChoices.isEmpty)
      }
      .padding(.top, 80)
      .padding(.horizontal, 36)
      .background(viewStore.backgroundColor)
      .task { await viewStore.send(.onTask).finish() }
      .alert(store: store.scope(state: \.$alert, action: { .alert($0) }))
      .frame(height: UIScreen.main.bounds.height)
      .onTapGesture {
        if !viewStore.voteChoices.isEmpty {
          viewStore.send(.continueButtonTapped)
        }
      }
    }
  }
}
