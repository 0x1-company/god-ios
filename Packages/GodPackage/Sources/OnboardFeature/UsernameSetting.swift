import Apollo
import Colors
import ComposableArchitecture
import God
import GodClient
import StringHelpers
import SwiftUI

public struct UsernameSettingLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    @PresentationState var alert: AlertState<Action.Alert>?
    @BindingState var username = ""
    var isDisabled = true
    var isActivityIndicatorVisible = false
    public init() {}
  }

  public enum Action: Equatable, BindableAction {
    case nextButtonTapped
    case binding(BindingAction<State>)
    case updateUsernameResponse(TaskResult<God.UpdateUsernameMutation.Data>)
    case delegate(Delegate)
    case alert(Alert)

    public enum Delegate: Equatable {
      case nextScreen
    }

    public enum Alert: Equatable {
      case confirmOkay
    }
  }

  @Dependency(\.godClient) var godClient

  public var body: some Reducer<State, Action> {
    BindingReducer()
    Reduce<State, Action> { state, action in
      switch action {
      case .nextButtonTapped:
        state.isActivityIndicatorVisible = true
        let input = God.UpdateUsernameInput(username: state.username)
        return .run { send in
          await send(.updateUsernameResponse(TaskResult {
            try await godClient.updateUsername(input)
          }))
        }

      case .binding:
        state.isDisabled = !validateUsername(for: state.username)
        return .none

      case .updateUsernameResponse(.success):
        state.isActivityIndicatorVisible = false
        return .send(.delegate(.nextScreen), animation: .default)

      case let .updateUsernameResponse(.failure(error as GodServerError)) where error.code == .badUserInput:
        state.isActivityIndicatorVisible = false
        state.alert = AlertState {
          TextState("Error", bundle: .module)
        } actions: {
          ButtonState(action: .confirmOkay) {
            TextState("OK", bundle: .module)
          }
        } message: {
          TextState("username must be a string at least 4 characters long and up to 30 characters long containing only letters, numbers, underscores, and periods except that no two periods shall be in sequence or undefined", bundle: .module)
        }
        return .none

      case let .updateUsernameResponse(.failure(error as GodServerError)) where error.code == .internal:
        state.isActivityIndicatorVisible = false
        state.alert = AlertState {
          TextState("Error", bundle: .module)
        } actions: {
          ButtonState(action: .confirmOkay) {
            TextState("OK", bundle: .module)
          }
        } message: {
          TextState("Sorry, that username is not available!", bundle: .module)
        }
        return .none

      case .updateUsernameResponse(.failure):
        state.isActivityIndicatorVisible = false
        return .none

      default:
        return .none
      }
    }
  }
}

public struct UsernameSettingView: View {
  let store: StoreOf<UsernameSettingLogic>
  @FocusState var focus: Bool

  public init(store: StoreOf<UsernameSettingLogic>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      VStack {
        Spacer()
        Text("Choose a username", bundle: .module)
          .bold()
          .foregroundColor(.white)

        TextField("Username", text: viewStore.$username)
          .textInputAutocapitalization(.never)
          .textContentType(.username)
          .font(.title)
          .foregroundColor(.white)
          .multilineTextAlignment(.center)
          .focused($focus)

        Spacer()

        NextButton(
          isLoading: viewStore.isActivityIndicatorVisible,
          isDisabled: viewStore.isDisabled
        ) {
          viewStore.send(.nextButtonTapped)
        }
      }
      .padding(.horizontal, 24)
      .padding(.bottom, 16)
      .background(Color.godService)
      .onAppear {
        focus = true
      }
    }
  }
}

struct UsernameSettingViewPreviews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      UsernameSettingView(
        store: .init(
          initialState: UsernameSettingLogic.State(),
          reducer: { UsernameSettingLogic() }
        )
      )
    }
  }
}
