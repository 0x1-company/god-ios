import ButtonStyles
import Colors
import ComposableArchitecture
import God
import GodClient
import SwiftUI

public struct HowToShareOnInstagramLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    public enum Step: Int, CaseIterable {
      case one = 1
      case two = 2
      case three = 3
      case four = 4

      var primaryButtonText: String {
        switch self {
        case .one, .two, .three:
          return "Next Step"
        case .four:
          return "Share on Instagram"
        }
      }

      var descriptionImageName: String {
        "how-tow-share-on-instagram-\(rawValue)"
      }
    }

    var allSteps: [Step] = Step.allCases
    var currentStep: Step = .one
    public init() {}
  }

  public enum Action: Equatable {
    case onTask
    case stepButtonTapped(State.Step)
    case primaryButtonTapped
    case closeButtonTapped
  }

  @Dependency(\.dismiss) var dismiss
  @Dependency(\.openURL) var openURL

  public var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .onTask:
        return .none

      case let .stepButtonTapped(step):
        state.currentStep = step
        return .none

      case .primaryButtonTapped:
        // Stepが最後の場合はInstagramへ飛ばす
        if state.currentStep == State.Step.allCases.last {
          guard let url = URL(string: "instagram-stories://share")
          else { return .none }
          return .run { _ in
            async let close = dismiss()
            async let open = openURL(url)
            _ = await (close, open)
          }
        }
        // 通常時は説明を次のStepへ
        if let nextStep = State.Step(rawValue: state.currentStep.rawValue + 1) {
          state.currentStep = nextStep
        }

        return .none
      case .closeButtonTapped:
        return .run { _ in
          await dismiss()
        }
      }
    }
  }
}

public struct HowToShareOnInstagramView: View {
  public static let heightForPresentationDetents: CGFloat = 260
  let store: StoreOf<HowToShareOnInstagramLogic>

  public init(store: StoreOf<HowToShareOnInstagramLogic>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      VStack(alignment: .center, spacing: 24) {
        Text("How to add the\nlink to your Story", bundle: .module)
          .font(.title)
          .bold()
          .foregroundColor(.godBlack)
          .lineSpacing(-2)
          .lineLimit(2)
          .multilineTextAlignment(.center)

        HStack(alignment: .center, spacing: 12) {
          ForEach(viewStore.allSteps, id: \.rawValue) { step in
            Button  {
              viewStore.send(.stepButtonTapped(step))
            } label: {
              Text(String(step.rawValue))
                .font(.subheadline)
                .foregroundColor(viewStore.state.currentStep == step ? .godWhite : .godBlack)
                .frame(width: 36, height: 36)
                .background(viewStore.state.currentStep == step ? Color.godBlack : Color.godWhite)
                .cornerRadius(18)
                .overlay(
                  viewStore.state.currentStep == step ? nil :
                    Circle()
                    .stroke(Color.godBlack, lineWidth: 0.5)
                )
            }
            .buttonStyle(HoldDownButtonStyle())
          }
        }

        RoundedRectangle(cornerRadius: 24)
          .fill(Color.red)
          .frame(maxWidth: .infinity)
          .frame(height: 240)

        Button {
          viewStore.send(.primaryButtonTapped)
        } label: {
          Text(viewStore.state.currentStep.primaryButtonText)
            .font(.subheadline)
            .bold()
            .foregroundColor(.godWhite)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(Color.godService)
            .cornerRadius(26)
            .overlay(
              RoundedRectangle(cornerRadius: 26)
                .stroke(Color.godService, lineWidth: 0.5)
            )
        }
        .buttonStyle(HoldDownButtonStyle())
      }
      .padding(20)
      .background(Color.godWhite)
      .cornerRadius(24)
      .task { await viewStore.send(.onTask).finish() }
    }
  }
}

struct HowToShareOnInstagramViewPreviews: PreviewProvider {
  static var previews: some View {
    Text("HowToShareOnInstagram")
      .sheet(
        isPresented: .constant(true)
      ) {
        HowToShareOnInstagramView(
          store: .init(
            initialState: HowToShareOnInstagramLogic.State(),
            reducer: { HowToShareOnInstagramLogic() }
          )
        )
        .presentationDetents([.fraction(0.3)])
        .presentationDragIndicator(.visible)
      }
  }
}
