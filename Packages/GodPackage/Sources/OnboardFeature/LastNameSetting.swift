import Apollo
import Colors
import ComposableArchitecture
import Contacts
import God
import GodClient
import StringHelpers
import SwiftUI
import UserDefaultsClient

public struct LastNameSettingLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    var doubleCheckName = DoubleCheckNameLogic.State()
    @PresentationState var alert: AlertState<Action.Alert>?
    @BindingState var lastName = ""
    var isDisabled = true
    var isImport = false
    public init() {}
  }

  public enum Action: Equatable, BindableAction {
    case onTask
    case nextButtonTapped
    case binding(BindingAction<State>)
    case updateProfileResponse(TaskResult<God.UpdateUserProfileMutation.Data>)
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
          let transformedLastName = try? transformToHiragana(for: contact.phoneticFamilyName)
        else { return .none }
        state.lastName = transformedLastName
        state.isImport = true
        return .none

      case .nextButtonTapped:
        let lastName = state.lastName
        guard
          !lastName.isEmpty,
          validateHiragana(for: lastName)
        else {
          state.alert = .hiraganaValidateError()
          return .none
        }
        let input = God.UpdateUserProfileInput(
          lastName: .init(stringLiteral: lastName)
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
        state.isDisabled = state.lastName.isEmpty
        return .none
      case .alert(.dismiss):
        state.alert = nil
        return .none
      default:
        return .none
      }
    }
  }
}

extension AlertState where Action == LastNameSettingLogic.Action.Alert {
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

public struct LastNameSettingView: View {
  let store: StoreOf<LastNameSettingLogic>
  @FocusState var focus: Bool

  public init(store: StoreOf<LastNameSettingLogic>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      VStack {
        Spacer()
        Text("What's your last name?", bundle: .module)
          .bold()
          .foregroundColor(.white)

        TextField("Last Name", text: viewStore.$lastName)
          .font(.title)
          .foregroundColor(.white)
          .multilineTextAlignment(.center)
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
      .task { await viewStore.send(.onTask).finish() }
      .toolbar {
        DoubleCheckNameView(
          store: store.scope(
            state: \.doubleCheckName,
            action: LastNameSettingLogic.Action.doubleCheckName
          )
        )
      }
      .alert(store: store.scope(state: \.$alert, action: LastNameSettingLogic.Action.alert))
      .onAppear {
        focus = true
      }
    }
  }
}

struct LastNameSettingViewPreviews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      LastNameSettingView(
        store: .init(
          initialState: LastNameSettingLogic.State(),
          reducer: { LastNameSettingLogic() }
        )
      )
    }
  }
}
