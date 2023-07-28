import ComposableArchitecture
import SwiftUI

public struct AddReducer: ReducerProtocol {
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

public struct AddView: View {
  let store: StoreOf<AddReducer>

  public init(store: StoreOf<AddReducer>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      List {
        Text("Add")
      }
      .navigationTitle("Add")
      .navigationBarTitleDisplayMode(.inline)
      .task { await viewStore.send(.onTask).finish() }
    }
  }
}

struct AddViewPreviews: PreviewProvider {
  static var previews: some View {
    AddView(
      store: .init(
        initialState: AddReducer.State(),
        reducer: AddReducer()
      )
    )
  }
}