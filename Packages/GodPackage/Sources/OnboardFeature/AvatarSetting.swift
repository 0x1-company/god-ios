import ComposableArchitecture
import SwiftUI

public struct AvatarSettingReducer: ReducerProtocol {
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

public struct AvatarSettingView: View {
  let store: StoreOf<AvatarSettingReducer>

  public init(store: StoreOf<AvatarSettingReducer>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      List {
        Text("AvatarSetting")
      }
      .navigationTitle("AvatarSetting")
      .navigationBarTitleDisplayMode(.inline)
      .task { await viewStore.send(.onTask).finish() }
    }
  }
}

struct AvatarSettingViewPreviews: PreviewProvider {
  static var previews: some View {
    AvatarSettingView(
      store: .init(
        initialState: AvatarSettingReducer.State(),
        reducer: AvatarSettingReducer()
      )
    )
  }
}
