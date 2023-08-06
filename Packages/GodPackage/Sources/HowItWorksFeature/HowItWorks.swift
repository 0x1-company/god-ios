import Colors
import ComposableArchitecture
import SwiftUI

public struct HowItWorksReducer: Reducer {
  public init() {}

  public struct State: Equatable {
    public init() {}
  }

  public enum Action: Equatable {
    case startButtonTapped
  }

  public var body: some Reducer<State, Action> {
    Reduce { _, action in
      switch action {
      case .startButtonTapped:
        return .none
      }
    }
  }
}

public struct HowItWorksView: View {
  let store: StoreOf<HowItWorksReducer>

  public init(store: StoreOf<HowItWorksReducer>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      VStack {
        Button {
          viewStore.send(.startButtonTapped)
        } label: {
          Text("Start")
            .bold()
            .frame(height: 54)
            .frame(maxWidth: .infinity)
        }
        .foregroundColor(Color.white)
        .background(Color.god.service)
        .clipShape(Capsule())
      }
      .padding(.horizontal, 16)
    }
  }
}

struct HowItWorksViewPreviews: PreviewProvider {
  static var previews: some View {
    HowItWorksView(
      store: .init(
        initialState: HowItWorksReducer.State(),
        reducer: { HowItWorksReducer() }
      )
    )
  }
}
