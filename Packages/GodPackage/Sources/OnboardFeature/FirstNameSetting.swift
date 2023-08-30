import Colors
import ComposableArchitecture
import Contacts
import ContactsClient
import God
import GodClient
import StringHelpers
import SwiftUI
import UserDefaultsClient
import Apollo

public struct FirstNameSettingReducer: Reducer {
  public init() {}

  public struct State: Equatable {
    var doubleCheckName = DoubleCheckNameReducer.State()
    @PresentationState var alert: AlertState<Action.Alert>?
    var firstName = ""
    public init() {}
  }

  public enum Action: Equatable {
    case onTask
    case firstNameChanged(String)
    case nextButtonTapped
    case updateProfileResponse(TaskResult<GraphQLResult<God.UpdateUserProfileMutation.Data>>)
    case alert(PresentationAction<Alert>)
    case delegate(Delegate)
    case doubleCheckName(DoubleCheckNameReducer.Action)

    public enum Delegate: Equatable {
      case nextScreen
    }

    public enum Alert: Equatable {
      case confirmOkay
    }
  }

  @Dependency(\.godClient) var godClient
  @Dependency(\.contacts) var contactsClient
  @Dependency(\.userDefaults) var userDefaults

  public var body: some Reducer<State, Action> {
    Scope(state: \.doubleCheckName, action: /Action.doubleCheckName) {
      DoubleCheckNameReducer()
    }
    Reduce { state, action in
      switch action {
      case .onTask:
        guard
          case .authorized = contactsClient.authorizationStatus(.contacts),
          let number = userDefaults.phoneNumber(),
          let contact = try? contactsClient.findByPhoneNumber(number: number).first
        else { return .none }
        state.firstName = contact.phoneticGivenName
        return .none

      case let .firstNameChanged(firstName):
        state.firstName = firstName
        return .none

      case .nextButtonTapped:
        let firstName = state.firstName
        guard
          !firstName.isEmpty,
          validateHiragana(for: firstName)
        else {
          state.alert = .hiraganaValidateError()
          return .none
        }
        let input = God.UpdateUserProfileInput(
          firstName: .init(stringLiteral: firstName)
        )
        return .run { send in
          async let next: Void = send(.delegate(.nextScreen))
          async let update: Void = send(
            .updateProfileResponse(
              TaskResult {
                try await godClient.updateUserProfile(input)
              }
            )
          )
          _ = await (next, update)
        }
      default:
        return .none
      }
    }
  }
}

extension AlertState where Action == FirstNameSettingReducer.Action.Alert {
  static func hiraganaValidateError() -> Self {
    Self {
      TextState("title")
    } actions: {
      ButtonState(action: .confirmOkay) {
        TextState("OK")
      }
    } message: {
      TextState("ひらがなのみ設定できます")
    }
  }
}

public struct FirstNameSettingView: View {
  let store: StoreOf<FirstNameSettingReducer>

  public init(store: StoreOf<FirstNameSettingReducer>) {
    self.store = store
  }

  struct ViewState: Equatable {
    let firstName: String
    let isDisabled: Bool

    init(state: FirstNameSettingReducer.State) {
      firstName = state.firstName
      isDisabled = state.firstName.isEmpty
    }
  }

  public var body: some View {
    WithViewStore(store, observe: ViewState.init) { viewStore in
      VStack {
        Spacer()
        Text("What's your first name?")
          .bold()
          .foregroundColor(.white)
        TextField(
          "First Name",
          text: viewStore.binding(
            get: \.firstName,
            send: FirstNameSettingReducer.Action.firstNameChanged
          )
        )
        .font(.title)
        .foregroundColor(.white)
        .multilineTextAlignment(.center)
        Spacer()
        NextButton(isDisabled: viewStore.isDisabled) {
          viewStore.send(.nextButtonTapped)
        }
      }
      .padding(.horizontal, 24)
      .padding(.bottom, 16)
      .background(Color.godService)
      .navigationBarBackButtonHidden()
      .task { await viewStore.send(.onTask).finish() }
      .toolbar {
        DoubleCheckNameView(
          store: store.scope(
            state: \.doubleCheckName,
            action: FirstNameSettingReducer.Action.doubleCheckName
          )
        )
      }
      .alert(store: store.scope(state: \.$alert, action: FirstNameSettingReducer.Action.alert))
    }
  }
}

struct FirstNameSettingViewPreviews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      FirstNameSettingView(
        store: .init(
          initialState: FirstNameSettingReducer.State(),
          reducer: { FirstNameSettingReducer() }
        )
      )
    }
  }
}
