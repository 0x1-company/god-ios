import ColorHex
import ComposableArchitecture
import SwiftUI

public struct WelcomeReducer: Reducer {
  public init() {}
  
  public struct State: Equatable {
    let ages: [String] = {
      var numbers = Array(0 ... 100).map(String.init)
      numbers.insert("- -", at: 13)
      return numbers
    }()
    
    var selection = "- -"
    public init() {}
  }
  
  public enum Action: Equatable {
    case loginButtonTapped
    case getStartedButtonTapped
    case ageChanged(String)
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
      self.ages = state.ages
      self.ageText = state.selection == "- -" ? "Enter your age" : state.selection
      self.selection = state.selection
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
          .foregroundColor(Color(0xFF8F_8F8F))
        Spacer()
        VStack(spacing: 24) {
          ZStack {
            if viewStore.selection == "- -" {
              Text("By entering your age you agree to our Terms and Privacy Policy")
                .frame(height: 54)
                .foregroundColor(Color(0xFF8F_8F8F))
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
                  .background(Color(0xFFED_6C43))
                  .clipShape(Capsule())
              }
              .padding(.horizontal, 16)
            }
          }
          
          Text(viewStore.ageText)
            .foregroundColor(Color(0xFFED_6C43))
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
      .background(Color(0xFF1E_1E1E))
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
