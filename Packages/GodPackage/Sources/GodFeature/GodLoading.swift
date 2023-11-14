import AnalyticsClient
import ComposableArchitecture
import Lottie
import SwiftUI

@Reducer
public struct GodLoadingLogic {
  public init() {}

  public struct State: Equatable {
    public init() {}
  }

  public enum Action {
    case onTask
  }

  @Dependency(\.analytics) var analytics

  public var body: some Reducer<State, Action> {
    Reduce<State, Action> { _, action in
      switch action {
      case .onTask:
        analytics.logScreen(screenName: "GodLoading", of: self)
        return .none
      }
    }
  }
}

public struct GodLoadingView: View {
  let store: StoreOf<GodLoadingLogic>

  public init(store: StoreOf<GodLoadingLogic>) {
    self.store = store
  }

  public var body: some View {
    ZStack(alignment: .center) {
      LottieView(animation: LottieAnimation.named("Loading", bundle: .module))
        .looping()
        .resizable()
        .padding(.horizontal, 100)

      Image(ImageResource.loading)
        .resizable()
        .scaledToFit()
        .padding(.horizontal, 120)
        .offset(y: 60)
    }
    .task { await store.send(.onTask).finish() }
  }
}

#Preview {
  GodLoadingView(
    store: .init(
      initialState: GodLoadingLogic.State(),
      reducer: { GodLoadingLogic() }
    )
  )
}
