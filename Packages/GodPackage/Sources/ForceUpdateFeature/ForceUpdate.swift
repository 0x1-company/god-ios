import ComposableArchitecture
import Constants
import FullScreenActionView
import SwiftUI

public struct ForceUpdateReducer: ReducerProtocol {
  public init() {}

  public struct State: Equatable {
    public init() {}
  }

  public enum Action: Equatable {
    case updateButtonTapped
  }

  @Dependency(\.openURL) var openURL

  public var body: some ReducerProtocol<State, Action> {
    Reduce { _, action in
      switch action {
      case .updateButtonTapped:
        return .run { _ in
          await self.openURL(Constants.appStoreURL)
        }
      }
    }
  }
}

public struct ForceUpdateView: View {
  let store: StoreOf<ForceUpdateReducer>

  public init(store: StoreOf<ForceUpdateReducer>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { _ in
      FullScreenActionView(
        "...おや？！Godのようすが...！\n安定してご利用いただくために、最新バージョンへのアップデートをお願いいたします。",
        actionTitle: "アップデートする",
        action: {}
      )
    }
  }
}

struct ForceUpdateViewPreviews: PreviewProvider {
  static var previews: some View {
    ForceUpdateView(
      store: .init(
        initialState: ForceUpdateReducer.State(),
        reducer: ForceUpdateReducer()
      )
    )
  }
}
