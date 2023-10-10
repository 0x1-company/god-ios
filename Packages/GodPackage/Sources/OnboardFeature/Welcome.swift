import AsyncValue
import ButtonStyles
import Colors
import ComposableArchitecture
import Lottie
import SwiftUI

public struct WelcomeLogic: Reducer {
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

  public enum Action: Equatable, BindableAction {
    case loginButtonTapped
    case getStartedButtonTapped
    case binding(BindingAction<State>)
    case alert(PresentationAction<Alert>)

    public enum Alert: Equatable {
      case confirmOkay
    }
  }

  public var body: some Reducer<State, Action> {
    BindingReducer()
    Reduce<State, Action> { state, action in
      switch action {
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
                .foregroundColor(Color.godTextSecondaryDark)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            } else {
              Button {
                viewStore.send(.getStartedButtonTapped)
              } label: {
                Text("Get Started", bundle: .module)
                  .bold()
                  .frame(height: 54)
                  .frame(maxWidth: .infinity)
                  .foregroundColor(Color.white)
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
          .foregroundColor(Color.godService)
          .bold()

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
      .alert(store: store.scope(state: \.$alert, action: WelcomeLogic.Action.alert))
      .toolbar {
        Button {
          store.send(.loginButtonTapped)
        } label: {
          Text("Log In", bundle: .module)
            .foregroundColor(Color.white)
        }
      }
    }
  }
}

struct WelcomeViewPreviews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      WelcomeView(
        store: .init(
          initialState: WelcomeLogic.State(),
          reducer: { WelcomeLogic() }
        )
      )
    }
  }
}
