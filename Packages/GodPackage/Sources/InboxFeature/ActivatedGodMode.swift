import ComposableArchitecture
import SwiftUI

public struct ActivatedGodModeReducer: Reducer {
  public init() {}

  public struct State: Equatable {
    public init() {}
  }

  public enum Action: Equatable {
    case onTask
  }

  public var body: some ReducerOf<Self> {
    Reduce { _, action in
      switch action {
      case .onTask:
        return .none
      }
    }
  }
}

public struct ActivatedGodModeView: View {
  let store: StoreOf<ActivatedGodModeReducer>

  public init(store: StoreOf<ActivatedGodModeReducer>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      List {
        Text("ActivatedGodMode")
      }
      .navigationTitle("ActivatedGodMode")
      .navigationBarTitleDisplayMode(.inline)
      .task { await viewStore.send(.onTask).finish() }
    }
  }
}

struct ActivatedGodModeViewPreviews: PreviewProvider {
  static var previews: some View {
    ActivatedGodModeView(
      store: .init(
        initialState: ActivatedGodModeReducer.State(),
        reducer: { ActivatedGodModeReducer() }
      )
    )
  }
}