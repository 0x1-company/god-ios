import ComposableArchitecture
import SwiftUI

public struct MaintenanceReducer: Reducer {
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

public struct MaintenanceView: View {
  let store: StoreOf<MaintenanceReducer>

  public init(store: StoreOf<MaintenanceReducer>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      List {
        Text("Maintenance")
      }
      .navigationTitle("Maintenance")
      .navigationBarTitleDisplayMode(.inline)
      .task { await viewStore.send(.onTask).finish() }
    }
  }
}

struct MaintenanceViewPreviews: PreviewProvider {
  static var previews: some View {
    MaintenanceView(
      store: .init(
        initialState: MaintenanceReducer.State(),
        reducer: { MaintenanceReducer() }
      )
    )
  }
}