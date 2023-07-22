import ComposableArchitecture
import SwiftUI

public struct FirstNameSettingReducer: ReducerProtocol {
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

public struct FirstNameSettingView: View {
  let store: StoreOf<FirstNameSettingReducer>

  public init(store: StoreOf<FirstNameSettingReducer>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      List {
        Text("FirstNameSetting")
      }
      .navigationTitle("FirstNameSetting")
      .navigationBarTitleDisplayMode(.inline)
      .task { await viewStore.send(.onTask).finish() }
    }
  }
}

struct FirstNameSettingViewPreviews: PreviewProvider {
  static var previews: some View {
    FirstNameSettingView(
      store: .init(
        initialState: FirstNameSettingReducer.State(),
        reducer: FirstNameSettingReducer()
      )
    )
  }
}