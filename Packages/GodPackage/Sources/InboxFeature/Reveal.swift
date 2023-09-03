import ButtonStyles
import Colors
import ComposableArchitecture
import SwiftUI

public struct RevealReducer: Reducer {
  public init() {}

  public struct State: Equatable {
    public init() {}
  }

  public enum Action: Equatable {
    case onTask
    case seeFullNameButtonTapped
  }

  public var body: some ReducerOf<Self> {
    Reduce { _, action in
      switch action {
      case .onTask:
        return .none
      case .seeFullNameButtonTapped:
        return .none
      }
    }
  }
}

public struct RevealView: View {
  let store: StoreOf<RevealReducer>

  public init(store: StoreOf<RevealReducer>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      VStack(spacing: 16) {
        VStack(spacing: 16) {
          Text("The first letter in their name is...")
            .font(.title3)
            .bold()

          Text("S")
            .font(.largeTitle)
            .bold()
            .foregroundColor(Color.godService)
        }
        VStack {
          Button {
            viewStore.send(.seeFullNameButtonTapped)
          } label: {
            Text("See Full Name")
              .bold()
              .frame(height: 56)
              .frame(maxWidth: .infinity)
              .foregroundColor(.white)
              .background(Color.godService)
              .clipShape(Capsule())
          }
          .buttonStyle(HoldDownButtonStyle())

          Text("You have 2 reveals")
            .foregroundColor(.godTextSecondaryLight)
        }
      }
      .padding(.horizontal, 16)
      .multilineTextAlignment(.center)
      .task { await viewStore.send(.onTask).finish() }
    }
  }
}

struct RevealViewPreviews: PreviewProvider {
  static var previews: some View {
    RevealView(
      store: .init(
        initialState: RevealReducer.State(),
        reducer: { RevealReducer() }
      )
    )
  }
}
