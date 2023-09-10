import Colors
import ComposableArchitecture
import LabeledButton
import SwiftUI

let mock = [
  "つきやま ともき",
  "さとや はたなか",
  "すずき みさき",
  "さとう だいすけ",
  "わたなべ りこ",
  "こばやし たくや",
  "なかむら ちえこ",
  "きむら まさや",
  "まつもと あみ",
  "たかはし ゆういち",
]

public struct VoteLogic: Reducer {
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

  public var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .onTask:
        state.choices = mock.shuffled().prefix(4).map { $0 }
        return .none

      case .answerButtonTapped:
        state.isAnswered = true
        return .none

      case .shuffleButtonTapped:
        state.choices = mock.shuffled().prefix(4).map { $0 }
        return .none

      case .skipButtonTapped:
        return .none

      case .continueButtonTapped:
        state.isAnswered = false
        return .none

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

public struct VoteView: View {
  let store: StoreOf<VoteLogic>

  public init(store: StoreOf<VoteLogic>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      VStack(spacing: 0) {
        Spacer()
        Image("books", bundle: .module)
          .resizable()
          .scaledToFit()
          .frame(height: 140)
        Text("理想の勉強仲間")
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
            Text("Tap to continue")
          } else {
            HStack(spacing: 0) {
              LabeledButton("シャッフル", systemImage: "shuffle") {
                viewStore.send(.shuffleButtonTapped)
              }
              LabeledButton("スキップ", systemImage: "forward.fill") {
                viewStore.send(.skipButtonTapped)
              }
            }
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
      .onTapGesture {
        viewStore.send(.continueButtonTapped)
      }
    }
  }
}

struct VoteViewPreviews: PreviewProvider {
  static var previews: some View {
    VoteView(
      store: .init(
        initialState: VoteLogic.State(),
        reducer: { VoteLogic() }
      )
    )
  }
}
