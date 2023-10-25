import ComposableArchitecture
import God
import GodClient
import Lottie
import Styleguide
import SwiftUI
import AnalyticsClient

public struct HowItWorksLogic: Reducer {
  public init() {}

  enum Step: Int, CaseIterable {
    case poll, congrats, voted
  }

  public struct State: Equatable {
    var gender: God.Gender?
    @BindingState var currentStep = Step.poll
    public init() {}
  }

  public enum Action: Equatable, BindableAction {
    case onTask
    case onAppear
    case startButtonTapped
    case currentUserResponse(TaskResult<God.CurrentUserQuery.Data>)
    case binding(BindingAction<State>)
    case delegate(Delegate)

    public enum Delegate: Equatable {
      case start
      case notifyRequest
    }
  }

  @Dependency(\.godClient) var godClient
  @Dependency(\.analytics) var analytics

  enum Cancel {
    case currentUser
  }

  public var body: some Reducer<State, Action> {
    BindingReducer()
    Reduce<State, Action> { state, action in
      switch action {
      case .onTask:
        return .run { send in
          await send(.delegate(.notifyRequest))
          for try await data in godClient.currentUser() {
            await send(.currentUserResponse(.success(data)))
          }
        } catch: { error, send in
          await send(.currentUserResponse(.failure(error)))
        }
        .cancellable(id: Cancel.currentUser, cancelInFlight: true)
        
      case .onAppear:
        analytics.logScreen(screenName: "HowItWorks", of: self)
        return .none

      case .startButtonTapped where state.currentStep == .voted:
        return .send(.delegate(.start), animation: .default)

      case .startButtonTapped:
        guard let nextStep = Step(rawValue: state.currentStep.rawValue + 1)
        else { return .none }
        state.currentStep = nextStep
        return .none

      case let .currentUserResponse(.success(data)):
        state.gender = data.currentUser.gender.value
        return .none

      case .currentUserResponse(.failure):
        state.gender = nil
        return .none

      case .binding:
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
      ZStack {
        TabView(selection: viewStore.$currentStep) {
          Image(ImageResource.poll)
            .resizable()
            .scaledToFit()
            .tag(HowItWorksLogic.Step.poll)
            .padding(.horizontal, 36)

          Image(ImageResource.congrats)
            .resizable()
            .scaledToFit()
            .tag(HowItWorksLogic.Step.congrats)
            .padding(.horizontal, 36)

          Image(viewStore.gender == .female ? ImageResource.votedForGirl : ImageResource.votedForBoy)
            .resizable()
            .scaledToFit()
            .tag(HowItWorksLogic.Step.voted)
            .padding(.horizontal, 36)
        }
        .tabViewStyle(PageTabViewStyle())

        VStack(spacing: 0) {
          LottieView(animation: LottieAnimation.named("Onboarding", bundle: .module))
            .looping()
            .resizable()
            .frame(height: 100)

          Spacer()

          Button {
            store.send(.startButtonTapped, animation: .default)
          } label: {
            Text("Start", bundle: .module)
              .font(.system(.body, design: .rounded, weight: .bold))
              .frame(height: 54)
              .frame(maxWidth: .infinity)
              .foregroundStyle(Color.white)
              .background(Color.godService)
              .clipShape(Capsule())
          }
          .padding(.horizontal, 16)
        }
        .buttonStyle(HoldDownButtonStyle())
      }
      .task { await store.send(.onTask).finish() }
      .onAppear { store.send(.onAppear) }
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
