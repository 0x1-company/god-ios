import AnalyticsClient
import ComposableArchitecture
import SwiftUI

@Reducer
public struct InvitationCodeLogic {
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
        analytics.logScreen(screenName: "InvitationCode", of: self)
        return .none
      }
    }
  }
}

public struct InvitationCodeView: View {
  let store: StoreOf<InvitationCodeLogic>

  public init(store: StoreOf<InvitationCodeLogic>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      List {
        Text("InvitationCode", bundle: .module)
      }
      .navigationTitle("InvitationCode")
      .navigationBarTitleDisplayMode(.inline)
      .task { await store.send(.onTask).finish() }
      .onAppear { store.send(.onAppear) }
    }
  }
}

#Preview {
  InvitationCodeView(
    store: .init(
      initialState: InvitationCodeLogic.State(),
      reducer: { InvitationCodeLogic() }
    )
  )
}
