import ButtonStyles
import Colors
import ComposableArchitecture
import FeedbackGeneratorClient
import LabeledButton
import SwiftUI

let mock = [
  "つきやま ともき",
  "はたなか さとや",
  "すずき みさき",
  "さとう だいすけ",
  "わたなべ りこ",
  "こばやし たくや",
  "なかむら ちえこ",
  "きむら まさや",
  "まつもと あみ",
  "たかはし ゆういち",
]

public struct PollLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    @PresentationState var alert: AlertState<Action.Alert>?
    var isAnswered = false
    var choices: [String] = []
    public init() {}
  }

  public enum Action: Equatable {
    case onTask
    case answerButtonTapped
    case shuffleButtonTapped
    case skipButtonTapped
    case continueButtonTapped
    case alert(PresentationAction<Alert>)

    public enum Alert: Equatable {
      case confirmOkay
    }
  }

  @Dependency(\.feedbackGenerator) var feedbackGenerator

  public var body: some Reducer<State, Action> {
    Reduce<State, Action> { state, action in
      switch action {
      case .onTask:
        state.choices = mock.shuffled().prefix(4).map { $0 }
        return .none

      case .answerButtonTapped:
        state.isAnswered = true
        return .none

      case .shuffleButtonTapped:
        state.choices = mock.shuffled().prefix(4).map { $0 }
        return .run { _ in
          await feedbackGenerator.mediumImpact()
        }
      case .skipButtonTapped:
        return .run { _ in
          await feedbackGenerator.mediumImpact()
        }
      case .continueButtonTapped:
        state.isAnswered = false
        return .run { _ in
          await feedbackGenerator.mediumImpact()
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
      ZStack {
        VStack(spacing: 0) {
          Spacer()
          Image(.books)
            .resizable()
            .scaledToFit()
            .frame(height: 140)
          Text("理想の勉強仲間", bundle: .module)
            .font(.title2)
            .foregroundColor(.white)
          Spacer()
          LazyVGrid(
            columns: Array(repeating: GridItem(spacing: 16), count: 2),
            spacing: 16
          ) {
            ForEach(viewStore.choices, id: \.self) { choice in
              AnswerButton(
                choice,
                progress: viewStore.isAnswered ? Double.random(in: 0.1 ..< 0.9) : 0.0
              ) {
                viewStore.send(.answerButtonTapped)
              }
              .disabled(viewStore.isAnswered)
            }
          }

          ZStack {
            if viewStore.isAnswered {
              Text("Tap to continue", bundle: .module)
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
        .onTapGesture {
          viewStore.send(.continueButtonTapped)
        }
        
        Text("1 of 12", bundle: .module)
          .foregroundColor(Color.white)
      }
      .task { await viewStore.send(.onTask).finish() }
      .alert(store: store.scope(state: \.$alert, action: { .alert($0) }))
    }
  }
}

#Preview {
  PollView(
    store: .init(
      initialState: PollLogic.State(),
      reducer: { PollLogic() }
    )
  )
}
