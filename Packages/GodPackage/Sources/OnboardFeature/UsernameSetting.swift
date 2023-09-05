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

    public enum Delegate: Equatable {
      case nextScreen
    }
  }

  @Dependency(\.godClient) var godClient

  public var body: some Reducer<State, Action> {
    BindingReducer()
    Reduce { state, action in
      switch action {
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
        
      case .binding:
        state.isDisabled = !validateUsername(for: state.username)
        return .none
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
  let store: StoreOf<UsernameSettingLogic>

  public init(store: StoreOf<UsernameSettingLogic>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      VStack {
        Spacer()
        Text("Choose a username")
          .bold()
          .foregroundColor(.white)

        TextField("Username", text: viewStore.$username)
        .textInputAutocapitalization(.never)
        .textContentType(.username)
        .font(.title)
        .foregroundColor(.white)
        .multilineTextAlignment(.center)

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
