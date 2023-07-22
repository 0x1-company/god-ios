import ComposableArchitecture
import SwiftUI

public struct LastNameSettingReducer: ReducerProtocol {
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

public struct LastNameSettingView: View {
  let store: StoreOf<LastNameSettingReducer>

  public init(store: StoreOf<LastNameSettingReducer>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      List {
        Text("LastNameSetting")
      }
      .navigationTitle("LastNameSetting")
      .navigationBarTitleDisplayMode(.inline)
      .task { await viewStore.send(.onTask).finish() }
    }
  }
}

struct LastNameSettingViewPreviews: PreviewProvider {
  static var previews: some View {
    LastNameSettingView(
      store: .init(
        initialState: LastNameSettingReducer.State(),
        reducer: LastNameSettingReducer()
      )
    )
  }
}