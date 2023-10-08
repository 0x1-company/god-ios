import Apollo
import ComposableArchitecture
import FirebaseAuth
import FirebaseAuthClient
import God
import GodClient
import PhoneNumberDependencies
import SwiftUI
import UserDefaultsClient

public struct OneTimeCodeLogic: Reducer {
  public struct State: Equatable {
    var inviterUserId: String?
    var phoneNumber = ""
    var isActivityIndicatorVisible = false
    @BindingState var oneTimeCode = ""
    @PresentationState var alert: AlertState<Action.Alert>?

    public init(inviterUserId: String?) {
      self.inviterUserId = inviterUserId
    }
  }

  public enum Action: Equatable, BindableAction {
    case onTask
    case resendButtonTapped
    case nextButtonTapped
    case verifyResponse(TaskResult<String?>)
    case signInResponse(TaskResult<AuthDataResult?>)
    case createUserResponse(TaskResult<God.CreateUserMutation.Data>)
    case alert(PresentationAction<Alert>)
    case delegate(Delegate)
    case binding(BindingAction<State>)

    public enum Delegate: Equatable {
      case nextScreen
      case popToRoot
    }

    public enum Alert: Equatable {
      case confirmOkay
    }
  }

  @Dependency(\.dismiss) var dismiss
  @Dependency(\.godClient) var godClient
  @Dependency(\.userDefaults) var userDefaults
  @Dependency(\.firebaseAuth) var firebaseAuth
  @Dependency(\.phoneNumberParse) var phoneNumberParse
  @Dependency(\.phoneNumberFormat) var phoneNumberFormat

  enum Cancel {
    case signUp
  }

  public var body: some Reducer<State, Action> {
    BindingReducer()
    Reduce<State, Action> { state, action in
      switch action {
      case .onTask:
        if let phoneNumber = userDefaults.phoneNumber() {
          state.phoneNumber = phoneNumber
          return .none
        }
        return .run { _ in
          await dismiss()
        }

      case .resendButtonTapped:
        state.oneTimeCode = ""
        return .run { [state] send in
          let phoneNumber = try phoneNumberParse(state.phoneNumber, withRegion: "JP", ignoreType: true)
          let format = phoneNumberFormat(phoneNumber)
          await send(.verifyResponse(TaskResult {
            try await firebaseAuth.verifyPhoneNumber(format)
          }))
        }
      case .nextButtonTapped:
        let oneTimeCode = state.oneTimeCode
        guard let id = userDefaults.verificationId() else {
          return .run { _ in
            await dismiss()
          }
        }
        let credential = firebaseAuth.credential(id, oneTimeCode)
        state.isActivityIndicatorVisible = true
        return .run { send in
          await send(.signInResponse(TaskResult {
            try await firebaseAuth.signIn(credential)
          }))
        }
        .cancellable(id: Cancel.signUp, cancelInFlight: true)
      case let .verifyResponse(.success(id)):
        return .run { _ in
          if let id {
            await userDefaults.setVerificationId(id)
          } else {
            await dismiss()
          }
        }
      case .verifyResponse(.failure):
        return .run { _ in
          await dismiss()
        }

      case .signInResponse(.success):
        guard let number = userDefaults.phoneNumber() else {
          state.isActivityIndicatorVisible = false
          return .run { _ in
            await dismiss()
          }
        }
        return .run { [state] send in
          let parseNumber = try phoneNumberParse(number, withRegion: "JP", ignoreType: true)
          let format = phoneNumberFormat(parseNumber)
          let phoneNumber = God.PhoneNumberInput(
            countryCode: "+81",
            numbers: format.replacing("+81", with: "")
          )
          let input = God.CreateUserInput(
            inviterUserId: state.inviterUserId ?? .null,
            phoneNumber: phoneNumber
          )
          await send(.createUserResponse(TaskResult {
            try await godClient.createUser(input)
          }))
        }
      case .signInResponse(.failure):
        state.isActivityIndicatorVisible = false
        return .run { _ in
          await dismiss()
        }

      case .createUserResponse(.success):
        state.isActivityIndicatorVisible = false
        return .run { @MainActor send in
          await userDefaults.setDynamicLinkURL(nil)
          send(.delegate(.nextScreen), animation: .default)
        }

      case .createUserResponse(.failure):
        state.isActivityIndicatorVisible = false
        return .send(.delegate(.popToRoot), animation: .default)

      case .alert(.presented(.confirmOkay)):
        state.alert = nil
        return .run { _ in
          await dismiss()
        }

//      case .binding(\.$oneTimeCode):
//        guard state.oneTimeCode.count >= 6 else {
//          return .none
//        }
//        return .send(.nextButtonTapped)

      default:
        return .none
      }
    }
  }
}

public struct OneTimeCodeView: View {
  let store: StoreOf<OneTimeCodeLogic>
  @FocusState var focus: Bool

  public init(store: StoreOf<OneTimeCodeLogic>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      ZStack {
        Color.godService
          .ignoresSafeArea()

        VStack(spacing: 12) {
          Spacer()
          Text("We sent you a code to verify\nyour number", bundle: .module)
            .bold()
            .font(.title3)

          TextField(
            text: viewStore.$oneTimeCode,
            label: {
              Text("000000", bundle: .module)
            }
          )
          .font(.title)
          .textContentType(.oneTimeCode)
          .keyboardType(.numberPad)
          .focused($focus)

          Spacer()

          VStack(spacing: 24) {
            NextButton(isLoading: viewStore.isActivityIndicatorVisible) {
              viewStore.send(.nextButtonTapped)
            }
          }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .foregroundColor(Color.white)
        .multilineTextAlignment(.center)
      }
      .alert(store: store.scope(state: \.$alert, action: OneTimeCodeLogic.Action.alert))
      .onAppear {
        focus = true
      }
    }
  }
}

struct OneTimeCodeViewPreviews: PreviewProvider {
  static var previews: some View {
    OneTimeCodeView(
      store: .init(
        initialState: OneTimeCodeLogic.State(
          inviterUserId: nil
        ),
        reducer: { OneTimeCodeLogic() }
      )
    )
  }
}
