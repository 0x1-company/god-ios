import ComposableArchitecture
import SwiftUI

public struct UsernameSettingReducer: ReducerProtocol {
  public init() {}

  public struct State: Equatable {
    var username = ""
    public init() {}
  }

  public enum Action: Equatable {
    case usernameChanged(String)
    case nextButtonTapped
  }

  public var body: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      switch action {
      case let .usernameChanged(username):
        state.username = username
        return .none

      case .nextButtonTapped:
        return .none
      }
    }
  }
}

public struct UsernameSettingView: View {
  let store: StoreOf<UsernameSettingReducer>

  struct ViewState: Equatable {
    var username: String
    var isNextButtonDisabled: Bool

    init(state: UsernameSettingReducer.State) {
      username = state.username
      isNextButtonDisabled = state.username.isEmpty
    }
  }

  public init(store: StoreOf<UsernameSettingReducer>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: ViewState.init) { viewStore in
      VStack {
        Spacer()
        Text("Choose a username")
          .bold()
          .foregroundColor(.white)

        TextField(
          "Username",
          text: viewStore.binding(
            get: \.username,
            send: UsernameSettingReducer.Action.usernameChanged
          )
        )
        .textInputAutocapitalization(.none)
        .textContentType(.username)
        .font(.title)
        .foregroundColor(.white)
        .multilineTextAlignment(.center)

        Spacer()

        Button {
          viewStore.send(.nextButtonTapped)
        } label: {
          Text("Next")
            .bold()
            .frame(height: 54)
            .frame(maxWidth: .infinity)
            .foregroundColor(Color.black)
            .background(Color.white)
            .clipShape(Capsule())
        }
        .disabled(viewStore.isNextButtonDisabled)
      }
      .padding(.horizontal, 24)
      .padding(.bottom, 16)
      .background(Color(0xFFED_6C43))
    }
  }
}

struct UsernameSettingViewPreviews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      UsernameSettingView(
        store: .init(
          initialState: UsernameSettingReducer.State(),
          reducer: UsernameSettingReducer()
        )
      )
    }
  }
}
