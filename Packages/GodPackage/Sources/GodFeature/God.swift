import ComposableArchitecture
import SwiftUI

public struct GodLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    public init() {}
  }

  public enum Action: Equatable {
    case onTask
  }

  public var body: some Reducer<State, Action> {
    Reduce<State, Action> { _, action in
      switch action {
      case .onTask:
        return .none
      }
    }
  }
}

public struct GodView: View {
  let store: StoreOf<GodLogic>

  public init(store: StoreOf<GodLogic>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      List {
        Text("God")
      }
      .navigationTitle("God")
      .navigationBarTitleDisplayMode(.inline)
      .task { await viewStore.send(.onTask).finish() }
    }
  }
}

struct GodViewPreviews: PreviewProvider {
  static var previews: some View {
    GodView(
      store: .init(
        initialState: GodLogic.State(),
        reducer: { GodLogic() }
      )
    )
  }
}
