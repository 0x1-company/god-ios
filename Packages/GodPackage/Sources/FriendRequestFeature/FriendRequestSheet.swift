import BackgroundClearSheet
import ComposableArchitecture
import God
import GodClient
import Styleguide
import SwiftUI

public struct FriendRequestSheetLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    public init() {}
  }

  public enum Action: Equatable {
    case onTask
  }
  
  @Dependency(\.godClient) var godClient

  public var body: some Reducer<State, Action> {
    Reduce<State, Action> { _, action in
      switch action {
      case .onTask:
        return .none
      }
    }
  }
}

public struct FriendRequestSheetView: View {
  let store: StoreOf<FriendRequestSheetLogic>

  public init(store: StoreOf<FriendRequestSheetLogic>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      VStack {
        Text("FriendRequestSheet", bundle: .module)
      }
      .navigationTitle("FriendRequestSheet")
      .navigationBarTitleDisplayMode(.inline)
      .task { await viewStore.send(.onTask).finish() }
    }
  }
}

#Preview {
  Color.red
    .ignoresSafeArea()
    .sheet(isPresented: .constant(true)) {
      FriendRequestSheetView(
        store: .init(
          initialState: FriendRequestSheetLogic.State(),
          reducer: { FriendRequestSheetLogic() }
        )
      )
    }
}
