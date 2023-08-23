import Colors
import ComposableArchitecture
import SwiftUI

public struct LaunchReducer: Reducer {
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

public struct LaunchView: View {
  let store: StoreOf<LaunchReducer>

  public init(store: StoreOf<LaunchReducer>) {
    self.store = store
  }

  public var body: some View {
    Color.godBlack
      .ignoresSafeArea()
  }
}
