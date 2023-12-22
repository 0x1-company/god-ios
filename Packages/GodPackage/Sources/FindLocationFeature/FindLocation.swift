import AnalyticsClient
import ComposableArchitecture
import Styleguide
import SwiftUI

@Reducer
public struct FindLocationLogic {
  public init() {}

  public struct State: Equatable {
    public init() {}
  }

  public enum Action {
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
        analytics.logScreen(screenName: "FindLocation", of: self)
        return .none
      }
    }
  }
}

public struct FindLocationView: View {
  let store: StoreOf<FindLocationLogic>

  public init(store: StoreOf<FindLocationLogic>) {
    self.store = store
  }

  public var body: some View {
    VStack(spacing: 0) {
      Spacer()

      VStack(spacing: 28) {
        Text("Connect your school to find friends", bundle: .module)
          .font(.system(.body, design: .rounded, weight: .bold))

        Button {} label: {
          HStack(spacing: 12) {
            Image(ImageResource.worldMap)
              .resizable()
              .aspectRatio(1, contentMode: .fit)
              .frame(width: 24, height: 24)

            Text("Find My School")
          }
          .font(.system(.body, design: .rounded, weight: .bold))
          .frame(height: 54)
          .frame(maxWidth: .infinity)
          .foregroundStyle(Color.black)
          .background(Color.white)
          .clipShape(Capsule())
        }
        .padding(.horizontal, 32)
      }

      Spacer()

      HStack(spacing: 0) {
        Image(systemName: "lock")

        Text("God cares intensely about your privacy.\nLocation is only used to find nearby schools.", bundle: .module)
          .multilineTextAlignment(.leading)
      }
      .foregroundStyle(Color.white)
    }
    .background(Color.godService)
    .task { store.send(.onTask) }
    .onAppear { store.send(.onAppear) }
  }
}

#Preview {
  FindLocationView(
    store: .init(
      initialState: FindLocationLogic.State(),
      reducer: { FindLocationLogic() }
    )
  )
}
