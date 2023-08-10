import ComposableArchitecture
import FirebaseAuthClient
import ProfileClient
import SwiftUI

public struct UsernameSettingReducer: Reducer {
  public init() {}

  public struct State: Equatable {
    var username = ""
    var isAvailableUsername = false
    public init() {}
  }

  public enum Action: Equatable {
    case usernameChanged(String)
    case isAvailableUsernameUpdated(Bool)
    case nextButtonTapped
    case delegate(Delegate)

    public enum Delegate: Equatable {
      case nextGenderSetting
    }
  }

  @Dependency(\.profileClient) var profileClient
  @Dependency(\.firebaseAuth.currentUser) var currentUser

  public var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case let .usernameChanged(username):
        enum CancelID { case effect }
        state.username = username
        return .run { [username = state.username] send in
          try await send(
            .isAvailableUsernameUpdated(
              profileClient.isAvailableUsername(username)
            )
          )
        } catch: { error, _ in
          print(error)
        }
        .cancellable(id: CancelID.effect, cancelInFlight: true)

      case let .isAvailableUsernameUpdated(isAvailableUsername):
        state.isAvailableUsername = isAvailableUsername
        return .none

      case .nextButtonTapped:
        guard let uid = currentUser()?.uid else {
          return .none
        }
        return .run { [username = state.username] send in
          try await profileClient.setUserProfile(
            uid: uid,
            field: .init(username: username)
          )
          await send(.delegate(.nextGenderSetting))
        } catch: { error, _ in
          print(error)
        }

      case .delegate:
        return .none
      }
    }
  }
}

public struct UsernameSettingView: View {
  let store: StoreOf<UsernameSettingReducer>

  struct ViewState: Equatable {
    var username: String
    var isDisabled: Bool

    init(state: UsernameSettingReducer.State) {
      username = state.username
      isDisabled = !state.isAvailableUsername
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

        NextButton(
          isLoading: false,
          isDisabled: viewStore.isDisabled
        ) {
          viewStore.send(.nextButtonTapped)
        }
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
          reducer: { UsernameSettingReducer() }
        )
      )
    }
  }
}
