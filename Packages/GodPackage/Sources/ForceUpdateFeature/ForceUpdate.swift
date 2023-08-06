import Colors
import ComposableArchitecture
import Constants
import SwiftUI

public struct ForceUpdateReducer: Reducer {
  public init() {}

  public struct State: Equatable {
    public init() {}
  }

  public enum Action: Equatable {
    case updateButtonTapped
  }

  @Dependency(\.openURL) var openURL

  public var body: some Reducer<State, Action> {
    Reduce { _, action in
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
  let store: StoreOf<ForceUpdateReducer>

  public init(store: StoreOf<ForceUpdateReducer>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      VStack(spacing: 24) {
        Text("お知らせ")
          .bold()
          .font(.title)
        Text("...おや？！Godのようすが...！\n最新バージョンへのアップデートをお願いします。")

        Button {
          viewStore.send(.updateButtonTapped)
        } label: {
          Text("アップデート")
            .bold()
            .frame(height: 56)
            .padding(.horizontal, 32)
        }
        .background(Color.white)
        .foregroundColor(Color.black)
        .clipShape(Capsule())
      }
      .padding(.horizontal, 24)
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(Color.god.service)
      .foregroundColor(Color.white)
      .multilineTextAlignment(.center)
    }
  }
}

struct ForceUpdateViewPreviews: PreviewProvider {
  static var previews: some View {
    ForceUpdateView(
      store: .init(
        initialState: ForceUpdateReducer.State(),
        reducer: { ForceUpdateReducer() }
      )
    )
  }
}
