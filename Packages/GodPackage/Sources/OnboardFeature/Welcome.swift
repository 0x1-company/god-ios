import AnalyticsClient
import AsyncValue
import ComposableArchitecture
import Lottie
import Styleguide
import SwiftUI

@Reducer
public struct WelcomeLogic {
  public init() {}

  public struct State: Equatable {
    @PresentationState var alert: AlertState<Action.Alert>?
    @BindingState var selection = "- -"
    var age = AsyncValue<String>.none
    let ages: [String] = {
      var numbers = Array(0 ... 100).map(String.init)
      numbers.insert("- -", at: 13)
      return numbers
    }()

    public init() {}
  }

  public enum Action: BindableAction {
    case onAppear
    case loginButtonTapped
    case getStartedButtonTapped
    case binding(BindingAction<State>)
    case alert(PresentationAction<Alert>)

    public enum Alert: Equatable {
      case confirmOkay
    }
  }

  @Dependency(\.analytics) var analytics

  public var body: some Reducer<State, Action> {
    BindingReducer()
    Reduce<State, Action> { state, action in
      switch action {
      case .onAppear:
        analytics.logScreen(screenName: "Welcome", of: self)
        return .none
      case .loginButtonTapped:
        return .none
      case .getStartedButtonTapped:
        return .none
      case .binding:
        state.age = state.selection == "- -" ? .none : .success(state.selection)
        if Array(0 ... 12).map(String.init).contains(state.selection) {
          state.alert = .init(
            title: {
              TextState("")
            },
            actions: {
              ButtonState(action: .send(.confirmOkay, animation: .default)) {
                TextState("OK", bundle: .module)
              }
            },
            message: {
              TextState("You must be at least 13 years old to sign up.", bundle: .module)
            }
          )
        }
        return .none
      case .alert(.presented(.confirmOkay)):
        state.alert = nil
        state.selection = "- -"
        return .none
      case .alert:
        return .none
      }
    }
  }
}

public struct WelcomeView: View {
  let store: StoreOf<WelcomeLogic>

  public init(store: StoreOf<WelcomeLogic>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      VStack {
        Spacer()
        LottieView(animation: LottieAnimation.named("onboarding", bundle: .module))
          .looping()
          .resizable()
          .padding(.horizontal, 84)
        Spacer()
        VStack(spacing: 24) {
          ZStack {
            if case .none = viewStore.age {
              Text("By entering your age you agree to our [Terms](https://docs.godapp.jp/terms-of-use) and [Privacy Policy](https://docs.godapp.jp/privacy-policy)", bundle: .module)
                .frame(height: 54)
                .foregroundStyle(Color.godTextSecondaryDark)
                .tint(Color.godTextSecondaryDark)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            } else {
              Button {
                store.send(.getStartedButtonTapped)
              } label: {
                Text("Get Started", bundle: .module)
                  .font(.system(.body, design: .rounded, weight: .bold))
                  .frame(height: 54)
                  .frame(maxWidth: .infinity)
                  .foregroundStyle(Color.white)
                  .background(Color.godService)
                  .clipShape(Capsule())
              }
              .buttonStyle(HoldDownButtonStyle())
              .padding(.horizontal, 16)
            }
          }

          Group {
            if case let .success(age) = viewStore.age {
              Text(verbatim: age)
            } else {
              Text("Enter your age", bundle: .module)
            }
          }
          .foregroundStyle(Color.godService)
          .font(.system(.body, design: .rounded, weight: .bold))

          Picker("", selection: viewStore.$selection) {
            ForEach(viewStore.ages, id: \.self) { value in
              Text(value).tag(value)
            }
          }
          .pickerStyle(.wheel)
          .environment(\.colorScheme, .dark)
        }
      }
      .background(Color.godBlack)
      .alert(store: store.scope(state: \.$alert, action: \.alert))
      .onAppear { store.send(.onAppear) }
      .toolbar {
        Button {
          store.send(.loginButtonTapped)
        } label: {
          Text("Log In", bundle: .module)
            .foregroundStyle(Color.white)
        }
      }
    }
  }
}

#Preview {
  NavigationStack {
    WelcomeView(
      store: .init(
        initialState: WelcomeLogic.State(),
        reducer: { WelcomeLogic() }
      )
    )
  }
}
