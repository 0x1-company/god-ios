import ComposableArchitecture
import Constants
import Styleguide
import SwiftUI

public struct ForceUpdateLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    public init() {}
  }

  public enum Action: Equatable {
    case updateButtonTapped
  }

  @Dependency(\.openURL) var openURL

  public var body: some Reducer<State, Action> {
    Reduce<State, Action> { _, action in
      switch action {
      case .updateButtonTapped:
        return .run { _ in
          await openURL(Constants.appStoreURL)
        }
      }
    }
  }
}

public struct ForceUpdateView: View {
  let store: StoreOf<ForceUpdateLogic>

  public init(store: StoreOf<ForceUpdateLogic>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      VStack(spacing: 24) {
        Text("お知らせ", bundle: .module)
          .font(.system(.title, design: .rounded, weight: .bold))
        Text("...おや？！Godのようすが...！\n最新バージョンへのアップデートをお願いします。", bundle: .module)

        Button {
          viewStore.send(.updateButtonTapped)
        } label: {
          Text("アップデート", bundle: .module)
            .font(.system(.body, design: .rounded, weight: .bold))
            .frame(height: 56)
            .padding(.horizontal, 32)
        }
        .background(Color.white)
        .foregroundStyle(Color.black)
        .clipShape(Capsule())
      }
      .padding(.horizontal, 24)
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(Color.godService)
      .foregroundStyle(Color.white)
      .multilineTextAlignment(.center)
    }
  }
}

struct ForceUpdateViewPreviews: PreviewProvider {
  static var previews: some View {
    ForceUpdateView(
      store: .init(
        initialState: ForceUpdateLogic.State(),
        reducer: { ForceUpdateLogic() }
      )
    )
  }
}
