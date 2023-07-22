import ComposableArchitecture
import SwiftUI

public struct HowItWorksReducer: ReducerProtocol {
  public init() {}

  public struct State: Equatable {
    public init() {}
  }

  public enum Action: Equatable {
    case onTask
  }

  public var body: some ReducerProtocol<State, Action> {
    Reduce { _, action in
      switch action {
        case .onTask:
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
      List {
        Text("HowItWorks")
      }
      .navigationTitle("HowItWorks")
      .navigationBarTitleDisplayMode(.inline)
      .task { await viewStore.send(.onTask).finish() }
    }
  }
}

struct HowItWorksViewPreviews: PreviewProvider {
  static var previews: some View {
    HowItWorksView(
      store: .init(
        initialState: HowItWorksReducer.State(),
        reducer: HowItWorksReducer()
      )
    )
  }
}