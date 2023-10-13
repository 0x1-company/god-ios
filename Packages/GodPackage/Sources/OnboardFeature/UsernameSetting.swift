import AnalyticsClient
import Apollo
import Styleguide
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
    case onAppear
    case nextButtonTapped
    case binding(BindingAction<State>)
    case updateUsernameResponse(TaskResult<God.UpdateUsernameMutation.Data>)
    case delegate(Delegate)
    case alert(PresentationAction<Alert>)

    public enum Delegate: Equatable {
      case nextScreen
    }

    public enum Alert: Equatable {
      case confirmOkay
    }
  }

  @Dependency(\.godClient) var godClient
  @Dependency(\.analytics) var analytics

  public var body: some Reducer<State, Action> {
    BindingReducer()
    Reduce<State, Action> { state, action in
      switch action {
      case .onAppear:
        analytics.logScreen(screenName: "UsernameSetting", of: self)
        return .none
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

      case let .updateUsernameResponse(.failure(error as GodServerError)) where error.code == .internal:
        state.isActivityIndicatorVisible = false
        let username = state.username
        state.alert = AlertState {
          TextState("Error", bundle: .module)
        } actions: {
          ButtonState(action: .confirmOkay) {
            TextState("OK", bundle: .module)
          }
        } message: {
          TextState("The username \(username) is not available.", bundle: .module)
        }
        return .none

      case .updateUsernameResponse(.failure):
        state.isActivityIndicatorVisible = false
        return .none

      case .alert(.presented(.confirmOkay)):
        state.alert = nil
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
      VStack(spacing: 8) {
        Spacer()
        Text("Choose a username", bundle: .module)
          .bold()
          .font(.title3)

        TextField(text: viewStore.$username) {
          Text("godappteam", bundle: .module)
        }
        .textInputAutocapitalization(.never)
        .textContentType(.username)
        .font(.title)
        .focused($focus)

        if viewStore.isDisabled {
          Text("Usernames can only use Roman latters (a-z, A-Z), numbers, underscores and periods", bundle: .module)
            .font(.footnote)
        }

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
      .foregroundStyle(Color.white)
      .background(Color.godService)
      .multilineTextAlignment(.center)
      .alert(store: store.scope(state: \.$alert, action: UsernameSettingLogic.Action.alert))
      .onAppear {
        focus = true
        store.send(.onAppear)
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
