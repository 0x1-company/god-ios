import ComposableArchitecture
import SwiftUI

public struct RootNavigationReducer: ReducerProtocol {
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

public struct RootNavigationView: View {
  let store: StoreOf<RootNavigationReducer>
  
  public init(store: StoreOf<RootNavigationReducer>) {
    self.store = store
  }
  
  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      List {
        Text("RootNavigation")
      }
      .navigationTitle("RootNavigation")
      .navigationBarTitleDisplayMode(.inline)
      .task { await viewStore.send(.onTask).finish() }
    }
  }
}

struct RootNavigationViewPreviews: PreviewProvider {
  static var previews: some View {
    RootNavigationView(
      store: .init(
        initialState: RootNavigationReducer.State(),
        reducer: RootNavigationReducer()
      )
    )
  }
}
