import ColorHex
import ComposableArchitecture
import LabeledButton
import SwiftUI

public struct QuestionReducer: ReducerProtocol {
  public init() {}

  public struct State: Equatable {
    public init() {}
  }

  public enum Action: Equatable {
    case onTask
    case shuffleButtonTapped
    case skipButtonTapped
    case continueButtonTapped
  }

  public var body: some ReducerProtocol<State, Action> {
    Reduce { _, action in
      switch action {
      case .onTask:
        return .none
      case .shuffleButtonTapped:
        return .none
      case .skipButtonTapped:
        return .none
      case .continueButtonTapped:
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
        Color(0xFF58_C150)
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
              AnswerButton("Ariana Duclos", progress: 0.1, action: {})
              AnswerButton("Allie Yarbrough", progress: 0.3, action: {})
              AnswerButton("Abby Arambula", progress: 0.5, action: {})
              AnswerButton("Ava Griego", progress: 0.9, action: {})
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
