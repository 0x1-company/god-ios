import ButtonStyles
import Colors
import ComposableArchitecture
import SwiftUI

public struct ShareTheAppLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    public init() {}
  }

  public enum Action: Equatable {
    case onTask
    case shareButtonTapped
  }

  public var body: some Reducer<State, Action> {
    Reduce<State, Action> { _, action in
      switch action {
      case .onTask:
        return .none

      case .shareButtonTapped:
        return .none
      }
    }
  }
}

public struct ShareTheAppView: View {
  let store: StoreOf<ShareTheAppLogic>

  public init(store: StoreOf<ShareTheAppLogic>) {
    self.store = store
  }

  public var body: some View {
    ZStack {
      Color.godService
        .ignoresSafeArea()
      VStack(spacing: 20) {
        Text("Get more\nfriends to play")
          .font(.title2)
          .foregroundStyle(Color.white)

        ShareLink(
          item: URL(string: "https://godapp.jp")!
        ) {
          Text("Share the app")
            .bold()
            .frame(width: 188, height: 54)
            .background(Color.white)
            .clipShape(Capsule())
        }
        .buttonStyle(HoldDownButtonStyle())
      }
      .multilineTextAlignment(.center)
    }
    .task { await store.send(.onTask).finish() }
  }
}

#Preview {
  ShareTheAppView(
    store: .init(
      initialState: ShareTheAppLogic.State(),
      reducer: { ShareTheAppLogic() }
    )
  )
}
