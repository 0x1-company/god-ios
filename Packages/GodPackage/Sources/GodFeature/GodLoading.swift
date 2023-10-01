import ComposableArchitecture
import Lottie
import SwiftUI

public struct GodLoadingLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    public init() {}
  }

  public enum Action: Equatable {
    case onTask
  }

  public var body: some Reducer<State, Action> {
    Reduce<State, Action> { _, action in
      switch action {
      case .onTask:
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
