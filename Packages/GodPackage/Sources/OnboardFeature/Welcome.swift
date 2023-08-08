import Colors
import ButtonStyles
import ComposableArchitecture
import SwiftUI

public struct WelcomeReducer: Reducer {
  public init() {}

  public struct State: Equatable {
    @PresentationState var alert: AlertState<Action.Alert>?
    var selection = "- -"
    let ages: [String] = {
      var numbers = Array(0 ... 100).map(String.init)
      numbers.insert("- -", at: 13)
      return numbers
    }()

    public init() {}
  }

  public enum Action: Equatable {
    case loginButtonTapped
    case getStartedButtonTapped
    case ageChanged(String)
    case alert(PresentationAction<Alert>)

    public enum Alert: Equatable {
      case confirmOkay
    }
  }

  public var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .loginButtonTapped:
        return .none
      case .getStartedButtonTapped:
        return .none
      case let .ageChanged(selection):
        state.selection = selection
        if Array(0 ... 12).map(String.init).contains(selection) {
          state.alert = .init(
            title: {
              TextState("Sorry")
            },
            actions: {
              ButtonState(action: .confirmOkay) {
                TextState("OK")
              }
            },
            message: {
              TextState("You must be at least 13 years old to sign up.")
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
  let store: StoreOf<WelcomeReducer>

  struct ViewState: Equatable {
    let ages: [String]
    let ageText: String
    let selection: String

    init(state: WelcomeReducer.State) {
      ages = state.ages
      ageText = state.selection == "- -" ? "Enter your age" : state.selection
      selection = state.selection
    }
  }

  public init(store: StoreOf<WelcomeReducer>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: ViewState.init) { viewStore in
      VStack {
        Spacer()
        Text("God")
          .font(.largeTitle)
          .bold()
          .foregroundColor(Color.god.textSecondaryDark)
        Spacer()
        VStack(spacing: 24) {
          ZStack {
            if viewStore.selection == "- -" {
              Text("By entering your age you agree to our Terms and Privacy Policy")
                .frame(height: 54)
                .foregroundColor(Color.god.textSecondaryDark)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            } else {
              Button {
                viewStore.send(.getStartedButtonTapped)
              } label: {
                Text("Get Started")
                  .bold()
                  .frame(height: 54)
                  .frame(maxWidth: .infinity)
                  .foregroundColor(Color.white)
                  .background(Color.god.service)
                  .clipShape(Capsule())
              }
              .buttonStyle(HoldDownButtonStyle())
              .padding(.horizontal, 16)
            }
          }

          Text(viewStore.ageText)
            .foregroundColor(Color.god.service)
            .bold()

          Picker(
            "",
            selection: viewStore.binding(
              get: \.selection,
              send: WelcomeReducer.Action.ageChanged
            )
            .animation(.default)
          ) {
            ForEach(viewStore.ages, id: \.self) { value in
              Text(value).tag(value)
            }
          }
          .pickerStyle(.wheel)
          .environment(\.colorScheme, .dark)
        }
      }
      .background(Color.god.black)
      .alert(store: store.scope(state: \.$alert, action: WelcomeReducer.Action.alert))
      .toolbar {
        Button("Log In") {}
          .foregroundColor(Color.white)
      }
    }
  }
}

struct WelcomeViewPreviews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      WelcomeView(
        store: .init(
          initialState: WelcomeReducer.State(),
          reducer: { WelcomeReducer() }
        )
      )
    }
  }
}
