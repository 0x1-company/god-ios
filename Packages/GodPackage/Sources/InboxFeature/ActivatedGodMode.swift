import AnalyticsClient
import ComposableArchitecture
import Styleguide
import SwiftUI

@Reducer
public struct ActivatedGodModeLogic {
  public init() {}

  public struct State: Equatable {
    public init() {}
  }

  public enum Action: Equatable {
    case onTask
    case onAppear
    case okayButtonTapped
  }

  @Dependency(\.dismiss) var dismiss
  @Dependency(\.analytics) var analytics

  public var body: some Reducer<State, Action> {
    Reduce<State, Action> { _, action in
      switch action {
      case .onTask:
        return .none

      case .onAppear:
        analytics.logScreen(screenName: "ActivatedGodMode", of: self)
        return .none

      case .okayButtonTapped:
        return .run { _ in
          await dismiss()
        }
      }
    }
  }
}

public struct ActivatedGodModeView: View {
  let store: StoreOf<ActivatedGodModeLogic>

  public init(store: StoreOf<ActivatedGodModeLogic>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { _ in
      VStack(spacing: 20) {
        Image(.activatedGodMode)
          .resizable()
          .scaledToFit()
          .padding(.horizontal, 60)
          .padding(.top, 20)

        Text("Tap a message in your inbox to reveal the sender", bundle: .module)
          .foregroundStyle(.white)
          .multilineTextAlignment(.center)

        Button {
          store.send(.okayButtonTapped)
        } label: {
          Text("OK", bundle: .module)
            .frame(height: 50)
            .frame(maxWidth: .infinity)
            .font(.system(.body, design: .rounded, weight: .bold))
            .foregroundStyle(.white)
            .background(Color.godGray)
            .clipShape(Capsule())
        }
        .buttonStyle(HoldDownButtonStyle())
      }
      .padding(.horizontal, 16)
      .frame(maxHeight: .infinity)
      .background(.black)
      .task { await store.send(.onTask).finish() }
      .onAppear { store.send(.onAppear) }
    }
  }
}

#Preview {
  Text("")
    .sheet(isPresented: .constant(true)) {
      ActivatedGodModeView(
        store: .init(
          initialState: ActivatedGodModeLogic.State(),
          reducer: { ActivatedGodModeLogic() }
        )
      )
      .presentationDetents([.fraction(0.4)])
    }
}
