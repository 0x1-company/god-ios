import ComposableArchitecture
import SwiftUI

public struct ShopReducer: ReducerProtocol {
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

public struct ShopView: View {
  let store: StoreOf<ShopReducer>

  public init(store: StoreOf<ShopReducer>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      List {
        Text("Shop")
      }
      .navigationTitle("Shop")
      .navigationBarTitleDisplayMode(.inline)
      .task { await viewStore.send(.onTask).finish() }
    }
  }
}

struct ShopViewPreviews: PreviewProvider {
  static var previews: some View {
    ShopView(
      store: .init(
        initialState: ShopReducer.State(),
        reducer: ShopReducer()
      )
    )
  }
}
