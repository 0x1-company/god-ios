import ComposableArchitecture
import SwiftUI

public struct GenderSettingReducer: Reducer {
  public init() {}

  public struct State: Equatable {
    public init() {}
  }

  public enum Action: Equatable {
    case onTask
  }

  public var body: some Reducer<State, Action> {
    Reduce { _, action in
      switch action {
      case .onTask:
        return .none
      }
    }
  }
}

public struct GenderSettingView: View {
  let store: StoreOf<GenderSettingReducer>

  public init(store: StoreOf<GenderSettingReducer>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      List {
        Text("GenderSetting")
      }
      .navigationTitle("GenderSetting")
      .navigationBarTitleDisplayMode(.inline)
      .task { await viewStore.send(.onTask).finish() }
    }
  }
}

struct GenderSettingViewPreviews: PreviewProvider {
  static var previews: some View {
    GenderSettingView(
      store: .init(
        initialState: GenderSettingReducer.State(),
        reducer: { GenderSettingReducer() }
      )
    )
  }
}
