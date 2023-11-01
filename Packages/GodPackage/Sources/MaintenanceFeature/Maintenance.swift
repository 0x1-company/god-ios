import ComposableArchitecture
import Styleguide
import SwiftUI

public struct MaintenanceLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    public init() {}
  }

  public enum Action: Equatable {
    case onTask
  }

  public var body: some Reducer<State, Action> {
    Reduce<State, Action> { _, action in
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
        Text("メンテナンス中", bundle: .module)
          .font(.system(.title, design: .rounded, weight: .bold))

        Text("サービス再開までしばらくお待ち下さい。", bundle: .module)
          .font(.system(.body, design: .rounded, weight: .bold))
      }
      .padding(.horizontal, 24)
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(Color.godService)
      .foregroundStyle(Color.white)
      .multilineTextAlignment(.center)
    }
  }
}

#Preview {
  MaintenanceView(
    store: .init(
      initialState: MaintenanceLogic.State(),
      reducer: { MaintenanceLogic() }
    )
  )
}
