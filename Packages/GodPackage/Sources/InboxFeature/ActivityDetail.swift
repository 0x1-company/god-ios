import ComposableArchitecture
import SwiftUI

public struct ActivityDetailReducer: Reducer {
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

public struct ActivityDetailView: View {
  let store: StoreOf<ActivityDetailReducer>

  public init(store: StoreOf<ActivityDetailReducer>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      List {
        Text("ActivityDetail")
      }
      .navigationTitle("ActivityDetail")
      .navigationBarTitleDisplayMode(.inline)
      .task { await viewStore.send(.onTask).finish() }
    }
  }
}

struct ActivityDetailViewPreviews: PreviewProvider {
  static var previews: some View {
    ActivityDetailView(
      store: .init(
        initialState: ActivityDetailReducer.State(),
        reducer: { ActivityDetailReducer() }
      )
    )
  }
}