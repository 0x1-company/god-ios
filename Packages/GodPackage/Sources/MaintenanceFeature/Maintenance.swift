import ComposableArchitecture
import Styleguide
import SwiftUI

@Reducer
public struct MaintenanceLogic {
  public init() {}

  public struct State: Equatable {
    public init() {}
  }

  public enum Action {}

  public var body: some Reducer<State, Action> {
    EmptyReducer()
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
        Text("Under Maintenance", bundle: .module)
          .font(.system(.title, design: .rounded, weight: .bold))

        Text("Please wait for a while until service resumes.", bundle: .module)
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
