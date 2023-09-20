import ComposableArchitecture
import Lottie
import SwiftUI

public struct CashOutLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    public init() {}
  }

  public enum Action: Equatable {
    case cashOutButtonTapped
    case delegate(Delegate)

    public enum Delegate: Equatable {
      case finish
    }
  }

  public var body: some Reducer<State, Action> {
    Reduce<State, Action> { _, action in
      switch action {
      case .cashOutButtonTapped:
        return .send(.delegate(.finish), animation: .default)

      case .delegate:
        return .none
      }
    }
  }
}

public struct CashOutView: View {
  let store: StoreOf<CashOutLogic>

  public init(store: StoreOf<CashOutLogic>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      ZStack {
        VStack(spacing: 88) {
          VStack(spacing: 100) {
            Text("Congrats", bundle: .module)
              .bold()
              .font(.largeTitle)

            Text("You earned 9 coins", bundle: .module)
              .bold()
          }

          Button {
            viewStore.send(.cashOutButtonTapped)
          } label: {
            Text("Cash Out", bundle: .module)
              .bold()
              .font(.title2)
              .frame(height: 54)
              .frame(maxWidth: .infinity)
              .foregroundColor(Color.black)
              .overlay(alignment: .leading) {
                Image(.moneyMouthFace)
                  .resizable()
                  .aspectRatio(contentMode: .fit)
                  .frame(width: 32, height: 32)
                  .clipped()
              }
              .padding(.horizontal, 16)
          }
          .background(Color.white)
          .clipShape(Capsule())
          .shadow(color: .black.opacity(0.2), radius: 25)
          .padding(.horizontal, 65)
        }

        LottieView(animation: LottieAnimation.named("coin", bundle: .module))
          .resizable()
          .padding(.bottom, 320)
      }
    }
  }
}

struct CashOutViewPreviews: PreviewProvider {
  static var previews: some View {
    CashOutView(
      store: .init(
        initialState: CashOutLogic.State(),
        reducer: { CashOutLogic() }
      )
    )
  }
}
