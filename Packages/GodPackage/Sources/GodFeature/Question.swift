import ColorHex
import ComposableArchitecture
import LabeledButton
import SwiftUI

public struct QuestionReducer: ReducerProtocol {
  public init() {}

  public struct State: Equatable {
    @PresentationState var alert: AlertState<Action.Alert>?
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

  public var body: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      switch action {
      case .onTask:
        return .none
        
      case .answerButtonTapped:
        return .none

      case .shuffleButtonTapped:
        return .none

      case .skipButtonTapped:
        return .none

      case .continueButtonTapped:
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
      case .alert:
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
      ZStack {
        Color(0xFF58C150)
          .ignoresSafeArea()

        VStack {
          Spacer()
          Text("Your ideal study buddy")
            .font(.title2)
            .foregroundColor(.white)
          Spacer()
          LazyVGrid(
            columns: Array(repeating: GridItem(spacing: 16), count: 2),
            spacing: 16,
            content: {
              AnswerButton("Ariana Duclos", progress: 0.1) {
                viewStore.send(.answerButtonTapped)
              }
              AnswerButton("Allie Yarbrough", progress: 0.3) {
                viewStore.send(.answerButtonTapped)
              }
              AnswerButton("Abby Arambula", progress: 0.5) {
                viewStore.send(.answerButtonTapped)
              }
              AnswerButton("Ava Griego", progress: 0.9) {
                viewStore.send(.answerButtonTapped)
              }
            }
          )

          ZStack {
            HStack(spacing: 0) {
              LabeledButton("Shuffle", systemImage: "shuffle") {
                viewStore.send(.shuffleButtonTapped)
              }
              LabeledButton("Skip", systemImage: "forward.fill") {
                viewStore.send(.skipButtonTapped)
              }
            }
            Button("Tap to continue") {
              viewStore.send(.continueButtonTapped)
            }
          }
          .foregroundColor(.white)
          .padding(.vertical, 64)
        }
        .padding(.horizontal, 36)
      }
      .alert(
        store: store.scope(
          state: \.$alert,
          action: { .alert($0) }
        )
      )
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
