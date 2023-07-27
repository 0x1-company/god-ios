import ColorHex
import ComposableArchitecture
import LabeledButton
import SwiftUI

let mock = [
  "Ariana Duclos",
  "Allie Yarbrough",
  "Abby Arambula",
  "Ava Griego",
  "Aron Jassinowsky",
  "Christopher Taylor",
  "Ellyse Pelletier",
  "Tomoki Tsukiyama",
  "Satoya Hatanaka",
]

public struct VoteReducer: ReducerProtocol {
  public init() {}

  public struct State: Equatable {
    @PresentationState var alert: AlertState<Action.Alert>?
    var isAnswered = false
    var choices = ["Ariana Duclos", "Allie Yarbrough", "Abby Arambula", "Ava Griego"]
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
        state.isAnswered.toggle()
        return .none

      case .shuffleButtonTapped:
        state.choices = mock.shuffled().prefix(4).map { $0 }
        return .none

      case .skipButtonTapped:
        return .none

      case .continueButtonTapped:
        state.isAnswered.toggle()
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
  let store: StoreOf<VoteReducer>

  public init(store: StoreOf<VoteReducer>) {
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
            spacing: 16
          ) {
            ForEach(viewStore.choices, id: \.self) { choice in
              AnswerButton(
                choice,
                progress: viewStore.isAnswered ? Double.random(in: 0.1 ..< 0.9) : 0.0
              ) {
                viewStore.send(.answerButtonTapped)
              }
            }
          }

          ZStack {
            if viewStore.isAnswered {
              Button("Tap to continue") {
                viewStore.send(.continueButtonTapped)
              }
            } else {
              HStack(spacing: 0) {
                LabeledButton("Shuffle", systemImage: "shuffle") {
                  viewStore.send(.shuffleButtonTapped)
                }
                LabeledButton("Skip", systemImage: "forward.fill") {
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

struct VoteViewPreviews: PreviewProvider {
  static var previews: some View {
    VoteView(
      store: .init(
        initialState: VoteReducer.State(),
        reducer: VoteReducer()
      )
    )
  }
}
