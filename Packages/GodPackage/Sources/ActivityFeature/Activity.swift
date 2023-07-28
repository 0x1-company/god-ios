import ComposableArchitecture
import SwiftUI

public struct ActivityReducer: ReducerProtocol {
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

public struct ActivityView: View {
  let store: StoreOf<ActivityReducer>

  public init(store: StoreOf<ActivityReducer>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      List {
        Text("Activity")
      }
      .navigationTitle("Activity")
      .navigationBarTitleDisplayMode(.inline)
      .task { await viewStore.send(.onTask).finish() }
    }
  }
}

struct ActivityViewPreviews: PreviewProvider {
  static var previews: some View {
    ActivityView(
      store: .init(
        initialState: ActivityReducer.State(),
        reducer: ActivityReducer()
      )
    )
  }
}
