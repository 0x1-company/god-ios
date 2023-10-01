import Apollo
import Colors
import ComposableArchitecture
import Contacts
import ContactsClient
import God
import GodClient
import StringHelpers
import SwiftUI
import UserDefaultsClient

public struct FirstNameSettingLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    var doubleCheckName = DoubleCheckNameLogic.State()
    @PresentationState var alert: AlertState<Action.Alert>?
    @BindingState var firstName = ""
    var isDisabled = true
    var isImport = false
    public init() {}
  }

  public enum Action: Equatable, BindableAction {
    case onTask
    case nextButtonTapped
    case updateProfileResponse(TaskResult<God.UpdateUserProfileMutation.Data>)
    case binding(BindingAction<State>)
    case alert(PresentationAction<Alert>)
    case delegate(Delegate)
    case doubleCheckName(DoubleCheckNameLogic.Action)

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
    BindingReducer()
    Scope(state: \.doubleCheckName, action: /Action.doubleCheckName) {
      DoubleCheckNameLogic()
    }
    Reduce<State, Action> { state, action in
      switch action {
      case .onTask:
        guard
          case .authorized = contactsClient.authorizationStatus(.contacts),
          let number = userDefaults.phoneNumber(),
          let contact = try? contactsClient.findByPhoneNumber(number: number).first,
          let transformedFirstName = try? transformToHiragana(for: contact.phoneticGivenName)
        else { return .none }
        state.firstName = transformedFirstName
        state.isImport = true
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
      case .binding:
        state.isImport = false
        state.isDisabled = state.firstName.isEmpty
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

extension AlertState where Action == FirstNameSettingLogic.Action.Alert {
  static func hiraganaValidateError() -> Self {
    Self {
      TextState("title", bundle: .module)
    } actions: {
      ButtonState(action: .confirmOkay) {
        TextState("OK", bundle: .module)
      }
    } message: {
      TextState("ひらがなのみ設定できます", bundle: .module)
    }
  }
}

public struct FirstNameSettingView: View {
  let store: StoreOf<FirstNameSettingLogic>
  @FocusState var focus: Bool

  public init(store: StoreOf<FirstNameSettingLogic>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      VStack {
        Spacer()
        Text("What's your first name?", bundle: .module)
          .bold()
          .foregroundColor(.godWhite)

        TextField(text: viewStore.$firstName) {
          Text("First Name", bundle: .module)
        }
        .foregroundColor(.white)
        .multilineTextAlignment(.center)
        .font(.title)
        .focused($focus)

        if viewStore.isImport {
          Text("Imported from Contacts", bundle: .module)
            .foregroundColor(.godWhite)
        }
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
            action: FirstNameSettingLogic.Action.doubleCheckName
          )
        )
      }
      .alert(store: store.scope(state: \.$alert, action: FirstNameSettingLogic.Action.alert))
      .onAppear {
        focus = true
      }
    }
  }
}

struct FirstNameSettingViewPreviews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      FirstNameSettingView(
        store: .init(
          initialState: FirstNameSettingLogic.State(),
          reducer: { FirstNameSettingLogic() }
        )
      )
    }
  }
}
