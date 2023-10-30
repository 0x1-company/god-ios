import AnalyticsClient
import ComposableArchitecture
import Lottie
import Styleguide
import SwiftUI

public struct CashOutLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    let earnedCoinAmount: Int
    public init(earnedCoinAmount: Int) {
      self.earnedCoinAmount = earnedCoinAmount
    }
  }

  public enum Action: Equatable {
    case onTask
    case cashOutButtonTapped
    case delegate(Delegate)

    public enum Delegate: Equatable {
      case finish
    }
  }

  @Dependency(\.analytics) var analytics

  public var body: some Reducer<State, Action> {
    Reduce<State, Action> { _, action in
      switch action {
      case .onTask:
        analytics.logScreen(screenName: "CashOut", of: self)
        return .none

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
              .font(.system(.largeTitle, design: .rounded, weight: .black))

            Text("You earned \(viewStore.earnedCoinAmount) coins", bundle: .module)
              .font(.system(.body, design: .rounded, weight: .bold))
          }

          Button {
            store.send(.cashOutButtonTapped)
          } label: {
            Text("Cash Out", bundle: .module)
              .font(.system(.title3, design: .rounded, weight: .bold))
              .frame(height: 54)
              .frame(maxWidth: .infinity)
              .foregroundStyle(Color.black)
              .overlay(alignment: .leading) {
                Image(.moneyMouthFace)
                  .resizable()
                  .aspectRatio(contentMode: .fit)
                  .frame(width: 32, height: 32)
                  .clipped()
              }
              .padding(.horizontal, 16)
              .background(Color.white)
              .clipShape(Capsule())
          }
          .shadow(color: .black.opacity(0.2), radius: 25)
          .buttonStyle(HoldDownButtonStyle())
          .padding(.horizontal, 65)
        }

        LottieView(animation: LottieAnimation.named("Coin", bundle: .module))
          .resizable()
          .padding(.bottom, 320)
      }
      .task { await store.send(.onTask).finish() }
    }
  }
}

#Preview {
  CashOutView(
    store: .init(
      initialState: CashOutLogic.State(
        earnedCoinAmount: 20
      ),
      reducer: { CashOutLogic() }
    )
  )
}
