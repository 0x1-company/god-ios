import ComposableArchitecture
import SwiftUI

public struct AppReducer: ReducerProtocol {
  public init() {}

  public struct State: Equatable {
    public init() {}

    var appDelegate = AppDelegateReducer.State()
  }

  public enum Action: Equatable {
    case appDelegate(AppDelegateReducer.Action)
  }

  @Dependency(\.openURL) var openURL

  public var body: some ReducerProtocol<State, Action> {
    Scope(state: \.appDelegate, action: /Action.appDelegate) {
      AppDelegateReducer()
    }
    Reduce { _, action in
      switch action {
      case .appDelegate:
        return .none
      }
    }
  }
}

public struct AppView: View {
  let store: StoreOf<AppReducer>

  public init(store: StoreOf<AppReducer>) {
    self.store = store
  }

  public var body: some View {
    NavigationStack {
      Text("AppView")
    }
  }
}
