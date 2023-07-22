import ComposableArchitecture
import SwiftUI

public struct SchoolSettingReducer: ReducerProtocol {
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

public struct SchoolSettingView: View {
  let store: StoreOf<SchoolSettingReducer>

  public init(store: StoreOf<SchoolSettingReducer>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      List {
        Text("SchoolSetting")
      }
      .navigationTitle("SchoolSetting")
      .navigationBarTitleDisplayMode(.inline)
      .task { await viewStore.send(.onTask).finish() }
    }
  }
}

struct SchoolSettingViewPreviews: PreviewProvider {
  static var previews: some View {
    SchoolSettingView(
      store: .init(
        initialState: SchoolSettingReducer.State(),
        reducer: SchoolSettingReducer()
      )
    )
  }
}
