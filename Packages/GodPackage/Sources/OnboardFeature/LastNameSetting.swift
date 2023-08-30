import Colors
import ComposableArchitecture
import Contacts
import God
import GodClient
import StringHelpers
import SwiftUI
import UserDefaultsClient

public struct LastNameSettingReducer: Reducer {
  public init() {}

  public struct State: Equatable {
    var doubleCheckName = DoubleCheckNameReducer.State()
    @PresentationState var alert: AlertState<Action.Alert>?
    var lastName = ""
    public init() {}
  }

  public enum Action: Equatable {
    case onTask
    case lastNameChanged(String)
    case nextButtonTapped
    case updateProfileResponse(TaskResult<God.UpdateUserProfileMutation.Data>)
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
        state.lastName = contact.phoneticFamilyName
        return .none

      case let .lastNameChanged(lastName):
        state.lastName = lastName
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
      default:
        return .none
      }
    }
  }
}

extension AlertState where Action == LastNameSettingReducer.Action.Alert {
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
  let store: StoreOf<LastNameSettingReducer>

  public init(store: StoreOf<LastNameSettingReducer>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      VStack {
        Spacer()
        Text("What's your last name?")
          .bold()
          .foregroundColor(.white)
        TextField(
          "Last Name",
          text: viewStore.binding(
            get: \.lastName,
            send: LastNameSettingReducer.Action.lastNameChanged
          )
        )
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
      }
      .padding(.horizontal, 24)
      .padding(.bottom, 16)
      .background(Color.godService)
      .task { await viewStore.send(.onTask).finish() }
      .toolbar {
        DoubleCheckNameView(
          store: store.scope(
            state: \.doubleCheckName,
            action: LastNameSettingReducer.Action.doubleCheckName
          )
        )
      }
      .alert(store: store.scope(state: \.$alert, action: LastNameSettingReducer.Action.alert))
    }
  }
}

struct LastNameSettingViewPreviews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      LastNameSettingView(
        store: .init(
          initialState: LastNameSettingReducer.State(),
          reducer: { LastNameSettingReducer() }
        )
      )
    }
  }
}
