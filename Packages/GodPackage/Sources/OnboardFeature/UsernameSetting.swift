import ComposableArchitecture
import SwiftUI

public struct UsernameSettingReducer: ReducerProtocol {
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

public struct UsernameSettingView: View {
  let store: StoreOf<UsernameSettingReducer>

  public init(store: StoreOf<UsernameSettingReducer>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      List {
        Text("UsernameSetting")
      }
      .navigationTitle("UsernameSetting")
      .navigationBarTitleDisplayMode(.inline)
      .task { await viewStore.send(.onTask).finish() }
    }
  }
}

struct UsernameSettingViewPreviews: PreviewProvider {
  static var previews: some View {
    UsernameSettingView(
      store: .init(
        initialState: UsernameSettingReducer.State(),
        reducer: UsernameSettingReducer()
      )
    )
  }
}