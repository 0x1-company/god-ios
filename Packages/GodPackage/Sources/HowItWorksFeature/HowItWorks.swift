import ComposableArchitecture
import God
import GodClient
import Lottie
import Styleguide
import SwiftUI

public struct HowItWorksLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    var gender: God.Gender?
    public init() {}
  }

  public enum Action: Equatable {
    case onTask
    case startButtonTapped
    case currentUserResponse(TaskResult<God.CurrentUserQuery.Data>)
    case delegate(Delegate)

    public enum Delegate: Equatable {
      case start
    }
  }

  @Dependency(\.godClient) var godClient

  enum Cancel {
    case currentUser
  }

  public var body: some Reducer<State, Action> {
    Reduce<State, Action> { state, action in
      switch action {
      case .onTask:
        return .run { send in
          for try await data in godClient.currentUser() {
            await send(.currentUserResponse(.success(data)))
          }
        } catch: { error, send in
          await send(.currentUserResponse(.failure(error)))
        }
        .cancellable(id: Cancel.currentUser, cancelInFlight: true)

      case .startButtonTapped:
        return .send(.delegate(.start), animation: .default)

      case let .currentUserResponse(.success(data)):
        state.gender = data.currentUser.gender.value
        return .none

      case .currentUserResponse(.failure):
        state.gender = nil
        return .none

      case .delegate:
        return .none
      }
    }
  }
}

public struct HowItWorksView: View {
  let store: StoreOf<HowItWorksLogic>

  public init(store: StoreOf<HowItWorksLogic>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      VStack(spacing: 100) {
        LottieView(animation: LottieAnimation.named("Onboarding", bundle: .module))
          .looping()
          .resizable()
          .frame(height: 100)

        Image(
          viewStore.gender == .female ? ImageResource.howItWorksForGirl : ImageResource.howItWorksForBoy
        )
        .resizable()
        .scaledToFit()

        Spacer()

        Button {
          viewStore.send(.startButtonTapped)
        } label: {
          Text("Start", bundle: .module)
            .bold()
            .frame(height: 54)
            .frame(maxWidth: .infinity)
            .foregroundColor(Color.white)
            .background(Color.godService)
            .clipShape(Capsule())
        }
        .buttonStyle(HoldDownButtonStyle())
      }
      .padding(.all, 16)
      .task { await store.send(.onTask).finish() }
    }
  }
}

struct HowItWorksViewPreviews: PreviewProvider {
  static var previews: some View {
    HowItWorksView(
      store: .init(
        initialState: HowItWorksLogic.State(),
        reducer: { HowItWorksLogic() }
      )
    )
  }
}
