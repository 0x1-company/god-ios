import AnalyticsClient
import ComposableArchitecture
import SwiftUI

@Reducer
public struct TutorialLogic {
  public init() {}

  public struct State: Equatable {
    public init() {}
  }

  public enum Action: Equatable {
    case onTask
    case onAppear
  }

  @Dependency(\.analytics) var analytics

  public var body: some Reducer<State, Action> {
    Reduce<State, Action> { _, action in
      switch action {
      case .onTask:
        return .none

      case .onAppear:
        analytics.logScreen(screenName: "Tutorial", of: self)
        return .none
      }
    }
  }
}

public struct TutorialView: View {
  let store: StoreOf<TutorialLogic>

  public init(store: StoreOf<TutorialLogic>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      List {
        Text("Tutorial", bundle: .module)
      }
      .navigationTitle("Tutorial")
      .navigationBarTitleDisplayMode(.inline)
      .task { await store.send(.onTask).finish() }
      .onAppear { store.send(.onAppear) }
    }
  }
}

#Preview {
  TutorialView(
    store: .init(
      initialState: TutorialLogic.State(),
      reducer: { TutorialLogic() }
    )
  )
}
