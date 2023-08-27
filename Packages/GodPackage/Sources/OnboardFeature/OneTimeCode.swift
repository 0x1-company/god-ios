import ComposableArchitecture
import FirebaseAuth
import FirebaseAuthClient
import SwiftUI
import UserDefaultsClient
import PhoneNumberClient
import God
import GodClient

public struct OneTimeCodeReducer: Reducer {
  public struct State: Equatable {
    var phoneNumber = ""
    var oneTimeCode = ""
    var isActivityIndicatorVisible = false
    @PresentationState var alert: AlertState<Action.Alert>?

    public init() {}
  }
  
  public enum Action: Equatable {
    case onTask
    case resendButtonTapped
    case nextButtonTapped
    case changeOneTimeCode(String)
    case verifyResponse(TaskResult<String?>)
    case signInResponse(TaskResult<AuthDataResult?>)
    case createUserResponse(TaskResult<God.CreateUserMutation.Data>)
    case alert(PresentationAction<Alert>)
    case delegate(Delegate)
    
    public enum Delegate: Equatable {
      case nextScreen
      case popToRoot
    }
    
    public enum Alert: Equatable {
      case confirmOkay
    }
  }

  @Dependency(\.dismiss) var dismiss
  @Dependency(\.userDefaults) var userDefaults
  @Dependency(\.phoneNumberClient) var phoneNumberClient
  @Dependency(\.firebaseAuth) var firebaseAuth
  @Dependency(\.godClient) var godClient
  
  public func reduce(into state: inout State, action: Action) -> Effect<Action> {
    switch action {
    case .onTask:
      guard let number = userDefaults.stringForKey("format-phone-number") else {
        return .run { _ in
          await dismiss()
        }
      }
      state.phoneNumber = number
      return .none

    case .resendButtonTapped:
      state.oneTimeCode = ""
      return .run { [state] send in
        await send(
          .verifyResponse(
            TaskResult {
              try await firebaseAuth.verifyPhoneNumber(state.phoneNumber)
            }
          )
        )
      }
    case .nextButtonTapped:
      let oneTimeCode = state.oneTimeCode
      guard let id = userDefaults.stringForKey("verify-id") else {
        return .run { _ in
          await dismiss()
        }
      }
      let credential = firebaseAuth.credential(id, oneTimeCode)
      state.isActivityIndicatorVisible = true
      return .run { send in
        await send(
          .signInResponse(
            TaskResult {
              try await firebaseAuth.signIn(credential)
            }
          )
        )
      }
    case let .verifyResponse(.success(id)):
      guard let verifyId = id else {
        return .run { _ in
          await dismiss()
        }
      }
      return .run { _ in
        await userDefaults.setString(verifyId, "verify-id")
      }
    case let .verifyResponse(.failure(error)):
      state.alert = AlertState {
        TextState("Error")
      } actions: {
        ButtonState(action: .send(.confirmOkay, animation: .default)) {
          TextState("OK")
        }
      } message: {
        TextState(error.localizedDescription)
      }
      return .none

    case let .changeOneTimeCode(code):
      state.oneTimeCode = code
      return .none
      
    case .signInResponse(.success):
      guard let number = userDefaults.stringForKey("format-phone-number") else {
        state.isActivityIndicatorVisible = false
        return .run { _ in
          await dismiss()
        }
      }
      let phoneNumber = God.PhoneNumberInput(
        countryCode: "+81",
        numbers: number.replacing("+81", with: "")
      )
      let input = God.CreateUserInput(phoneNumber: phoneNumber)
      return .run { send in
        await send(
          .createUserResponse(
            TaskResult {
              try await godClient.createUser(input)
            }
          )
        )
      }
    case let .signInResponse(.failure(error)):
      state.isActivityIndicatorVisible = false
      state.alert = AlertState {
        TextState("Error")
      } actions: {
        ButtonState(action: .send(.confirmOkay, animation: .default)) {
          TextState("OK")
        }
      } message: {
        TextState(error.localizedDescription)
      }
      return .none
      
    case .createUserResponse(.success):
      state.isActivityIndicatorVisible = false
//      return .run(priority: .high) { @MainActor send in
      return .run { @MainActor send in
        send(.delegate(.nextScreen), animation: .default)
      }
      
    case .createUserResponse(.failure):
      state.isActivityIndicatorVisible = false
      return .send(.delegate(.popToRoot), animation: .default)
      
    case .alert(.presented(.confirmOkay)):
      return .run { _ in
        await dismiss()
      }
      
    case .alert:
      return .none

    case .delegate:
      return .none
    }
  }
}

public struct OneTimeCodeView: View {
  let store: StoreOf<OneTimeCodeReducer>

  public init(store: StoreOf<OneTimeCodeReducer>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      ZStack {
        Color.godService
          .ignoresSafeArea()

        VStack(spacing: 12) {
          Spacer()
          Text("We sent you a code to verify\nyour number")
            .bold()
            .font(.title3)

          Text("Sent to +81 80-2332-3620")

          TextField(
            "Code",
            text: viewStore.binding(
              get: \.oneTimeCode,
              send: OneTimeCodeReducer.Action.changeOneTimeCode
            )
          )
          .font(.title)
          .textContentType(.oneTimeCode)
          .keyboardType(.numberPad)

          Spacer()

          VStack(spacing: 24) {
            Button("Resend in 30") {
              viewStore.send(.resendButtonTapped)
            }
            .bold()

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
      .alert(store: store.scope(state: \.$alert, action: OneTimeCodeReducer.Action.alert))
    }
  }
}

struct OneTimeCodeViewPreviews: PreviewProvider {
  static var previews: some View {
    OneTimeCodeView(
      store: .init(
        initialState: OneTimeCodeReducer.State(),
        reducer: { OneTimeCodeReducer() }
      )
    )
  }
}
