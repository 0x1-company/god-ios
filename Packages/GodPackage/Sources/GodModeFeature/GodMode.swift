import ComposableArchitecture
import SwiftUI

public struct GodModeReducer: Reducer {
  public init() {}

  public struct State: Equatable {
    public init() {}
  }

  public enum Action: Equatable {
    case onTask
  }

  public var body: some Reducer<State, Action> {
    Reduce { _, action in
      switch action {
      case .onTask:
        return .none
      }
    }
  }
}

public struct GodModeView: View {
  let store: StoreOf<GodModeReducer>

  public init(store: StoreOf<GodModeReducer>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { _ in
      VStack(spacing: 24) {
        Text("Recurring billing. Cancel anytime.\nYour payment will be charged to iTunes Account, and your subscription will auto-renew for ¥960/week until you cancel in iTunes Store settings. By tapping Unlock, you agree to our Terms and the auto-renewal.")
          .font(.caption)
          .padding(.horizontal, 24)
          .foregroundColor(Color.gray)
          .multilineTextAlignment(.center)

        VStack(spacing: 16) {
          Text("See who likes you")
          Text("with GOD MODE")

          Text("¥960/week")

          Button(action: {}) {
            Text("Continue")
              .bold()
              .frame(height: 56)
              .frame(maxWidth: .infinity)
              .foregroundColor(Color.white)
              .background(Color.orange.gradient)
              .clipShape(Capsule())
          }
          .padding(.horizontal, 60)

          Button(action: {}) {
            Text("Maybe Later")
              .foregroundColor(Color.gray)
          }
        }
        .foregroundColor(Color.white)
        .padding(.vertical, 24)
        .background(Color.black.gradient)
        .cornerRadius(32 / 2)
        .overlay(
          RoundedRectangle(cornerRadius: 32 / 2)
            .stroke(Color.orange, lineWidth: 2)
        )
        .padding(.horizontal, 8)

        Spacer()
      }
    }
  }
}

struct GodModeViewPreviews: PreviewProvider {
  static var previews: some View {
    GodModeView(
      store: .init(
        initialState: GodModeReducer.State(),
        reducer: GodModeReducer()
      )
    )
  }
}
