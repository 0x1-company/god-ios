import ComposableArchitecture
import SwiftUI

public struct ManageAccountReducer: ReducerProtocol {
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

public struct ManageAccountView: View {
  let store: StoreOf<ManageAccountReducer>

  public init(store: StoreOf<ManageAccountReducer>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      List {
        Text("ManageAccount")
      }
      .navigationTitle("ManageAccount")
      .navigationBarTitleDisplayMode(.inline)
      .task { await viewStore.send(.onTask).finish() }
    }
  }
}

struct ManageAccountViewPreviews: PreviewProvider {
  static var previews: some View {
    ManageAccountView(
      store: .init(
        initialState: ManageAccountReducer.State(),
        reducer: ManageAccountReducer()
      )
    )
  }
}