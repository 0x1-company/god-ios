import ComposableArchitecture
import SwiftUI

public struct WelcomeReducer: ReducerProtocol {
  public init() {}

  public struct State: Equatable {
    let ages: [String] = {
      var numbers = Array(0 ... 100).map(String.init)
      numbers.insert("- -", at: 13)
      return numbers
    }()

    @BindingState var selection = "- -"
    public init() {}
  }

  public enum Action: Equatable, BindableAction {
    case binding(BindingAction<State>)
  }

  public var body: some ReducerProtocol<State, Action> {
    BindingReducer()
    Reduce { _, action in
      switch action {
      case .binding:
        return .none
      }
    }
  }
}

public struct WelcomeView: View {
  let store: StoreOf<WelcomeReducer>

  public init(store: StoreOf<WelcomeReducer>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      VStack {
        Spacer()
        Text("Gas")
        Spacer()
        VStack(spacing: 24) {
          Text("By entering your age you agree to our Terms and Privacy Policy")
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 32)

          Text("Enter your age")
            .foregroundColor(.orange)
            .bold()

          Picker("", selection: viewStore.binding(\.$selection)) {
            ForEach(viewStore.ages, id: \.self) { value in
              Text(value).tag(value)
            }
          }
          .pickerStyle(.wheel)
        }
      }
      .toolbar {
        Button("Log In") {}
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
          reducer: WelcomeReducer()
        )
      )
    }
  }
}
