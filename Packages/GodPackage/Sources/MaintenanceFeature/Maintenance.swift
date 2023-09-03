import Colors
import ComposableArchitecture
import SwiftUI

public struct MaintenanceLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    public init() {}
  }

  public enum Action: Equatable {
    case onTask
  }

  public var body: some ReducerOf<Self> {
    Reduce { _, action in
      switch action {
      case .onTask:
        return .none
      }
    }
  }
}

public struct MaintenanceView: View {
  let store: StoreOf<MaintenanceLogic>

  public init(store: StoreOf<MaintenanceLogic>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { _ in
      VStack(spacing: 24) {
        Text("メンテナンス中")
          .bold()
          .font(.title)
        Text("サービス再開までしばらくお待ち下さい。")
      }
      .padding(.horizontal, 24)
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(Color.godService)
      .foregroundColor(Color.white)
      .multilineTextAlignment(.center)
    }
  }
}

struct MaintenanceViewPreviews: PreviewProvider {
  static var previews: some View {
    MaintenanceView(
      store: .init(
        initialState: MaintenanceLogic.State(),
        reducer: { MaintenanceLogic() }
      )
    )
  }
}
