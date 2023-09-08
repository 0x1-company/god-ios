import ButtonStyles
import Colors
import ComposableArchitecture
import SwiftUI
import Lottie

public struct HowItWorksLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    public init() {}
  }

  public enum Action: Equatable {
    case startButtonTapped
    case delegate(Delegate)

    public enum Delegate: Equatable {
      case start
    }
  }

  public var body: some Reducer<State, Action> {
    Reduce { _, action in
      switch action {
      case .startButtonTapped:
        return .send(.delegate(.start), animation: .default)

      case .delegate:
        return .none
      }
    }
  }
}

public struct HowItWorksView: View {
  let store: StoreOf<HowItWorksLogic>

  public init(store: StoreOf<HowItWorksLogic>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      VStack(spacing: 100) {
        LottieView(animation: LottieAnimation.named("onboarding", bundle: .module))
          .looping()
          .resizable()
          .frame(height: 100)
        Image("how-it-works-boy", bundle: .module)
          .resizable()
          .scaledToFit()
        Spacer()
        Button {
          viewStore.send(.startButtonTapped)
        } label: {
          Text("Start")
            .bold()
            .frame(height: 54)
            .frame(maxWidth: .infinity)
            .foregroundColor(Color.white)
            .background(Color.godService)
            .clipShape(Capsule())
        }
        .buttonStyle(HoldDownButtonStyle())
      }
      .padding(.all, 16)
    }
  }
}

struct HowItWorksViewPreviews: PreviewProvider {
  static var previews: some View {
    HowItWorksView(
      store: .init(
        initialState: HowItWorksLogic.State(),
        reducer: { HowItWorksLogic() }
      )
    )
  }
}
