import Apollo
import Colors
import ComposableArchitecture
import God
import GodClient
import StringHelpers
import SwiftUI

public struct UsernameSettingReducer: Reducer {
  public init() {}

  public struct State: Equatable {
    var username = ""
    var isDisabled = true
    var isValidUsername = false
    var isActivityIndicatorVisible = false
    public init() {}
  }

  public enum Action: Equatable {
    case usernameChanged(String)
    case nextButtonTapped
    case updateUsernameResponse(TaskResult<God.UpdateUsernameMutation.Data>)
    case delegate(Delegate)

    public enum Delegate: Equatable {
      case nextScreen
    }
  }

  @Dependency(\.godClient) var godClient

  public var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case let .usernameChanged(username):
        state.username = username
        state.isValidUsername = validateUsername(for: username)
        return .none

      case .nextButtonTapped:
        state.isActivityIndicatorVisible = true
        let input = God.UpdateUsernameInput(username: state.username)
        return .run { send in
          await send(
            .updateUsernameResponse(
              TaskResult {
                try await godClient.updateUsername(input)
              }
            )
          )
        }
      case .updateUsernameResponse(.success):
        state.isActivityIndicatorVisible = false
        return .send(.delegate(.nextScreen), animation: .default)

      case let .updateUsernameResponse(.failure(error as GodServerError)):
        state.isActivityIndicatorVisible = false
        print(error)
        return .none

      case .updateUsernameResponse(.failure):
        state.isActivityIndicatorVisible = false
        return .none

      case .delegate:
        return .none
      }
    }
  }
}

public struct UsernameSettingView: View {
  let store: StoreOf<UsernameSettingReducer>

  public init(store: StoreOf<UsernameSettingReducer>) {
    self.store = store
  }

  struct ViewState: Equatable {
    let username: String
    let isLoading: Bool
    let isDisabled: Bool
    init(state: UsernameSettingReducer.State) {
      username = state.username
      isLoading = state.isActivityIndicatorVisible
      isDisabled = !state.isValidUsername
    }
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
        .textInputAutocapitalization(.never)
        .textContentType(.username)
        .font(.title)
        .foregroundColor(.white)
        .multilineTextAlignment(.center)

        Spacer()

        NextButton(
          isLoading: viewStore.isLoading,
          isDisabled: viewStore.isDisabled
        ) {
          viewStore.send(.nextButtonTapped)
        }
      }
      .padding(.horizontal, 24)
      .padding(.bottom, 16)
      .background(Color.godService)
    }
  }
}

struct UsernameSettingViewPreviews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      UsernameSettingView(
        store: .init(
          initialState: UsernameSettingReducer.State(),
          reducer: { UsernameSettingReducer() }
        )
      )
    }
  }
}
