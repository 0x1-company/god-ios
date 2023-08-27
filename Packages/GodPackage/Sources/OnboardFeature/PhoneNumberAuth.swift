import ComposableArchitecture
import God
import GodClient
import FirebaseAuth
import FirebaseAuthClient

public struct PhoneNumberAuthReducer: Reducer {
  public struct State: Equatable {
    @PresentationState var alert: AlertState<Action.Alert>?

    var phoneNumber = ""
    var verifyId = ""
    var oneTimeCode = ""
    
    var isActivityIndicatorVisible = false
    
    public init() {}
  }

  public enum Action: Equatable {
    case onTask
    case alert(PresentationAction<Alert>)
    case delegate(Delegate)
    
    case changePhoneNumber(String)
    case verifyRequest
    case verifyResponse(TaskResult<String?>)
    case changeOneTimeCode(String)
    case signInRequest
    case signInResponse(TaskResult<AuthDataResult?>)
    case createUserResponse(TaskResult<God.CreateUserMutation.Data>)
    
    case nextFromPhoneNumberButtonTapped
    case nextFromOneTimeCodeButtonTapped
    case resendButtonTapped
    
    public enum Alert: Equatable {
      case confirmOkay
    }
    
    public enum Delegate: Equatable {
      case nextScreenFromPhoneNumber
      case nextScreenFromOneTimeCode
    }
  }
  
  @Dependency(\.dismiss) var dismiss
  @Dependency(\.godClient) var godClient
  @Dependency(\.firebaseAuth) var firebaseAuth
  @Dependency(\.phoneNumberClient) var phoneNumberClient

  public func reduce(into state: inout State, action: Action) -> Effect<Action> {
    switch action {
    case let .changePhoneNumber(phoneNumber):
      state.phoneNumber = phoneNumber
      return .none

    case .verifyRequest:
      return .run { [number = state.phoneNumber] send in
        let formatNumber = try phoneNumberClient.parseFormat(number)
        await send(
          .verifyResponse(
            TaskResult {
              try await firebaseAuth.verifyPhoneNumber(formatNumber)
            }
          )
        )
      }

    case let .verifyResponse(.success(.some(id))):
      state.verifyId = id
      return .none

    case let .verifyResponse(.failure(error)):
      print(error)
      state.alert = AlertState {
        TextState("Error")
      } actions: {
        ButtonState {
          TextState("OK")
        }
      } message: {
        TextState(error.localizedDescription)
      }
      return .none
      
    case let .changeOneTimeCode(oneTimeCode):
      state.oneTimeCode = oneTimeCode
      return .none
      
    case .signInRequest:
      state.isActivityIndicatorVisible = true
      let credential = firebaseAuth.credential(state.verifyId, state.oneTimeCode)
      return .run { send in
        await send(
          .signInResponse(
            TaskResult {
              try await firebaseAuth.signIn(credential)
            }
          )
        )
      }
    case .signInResponse(.success):
      print("sign in response")
      let phoneNumber = God.PhoneNumberInput(
        countryCode: "81",
        numbers: state.phoneNumber
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
      print(error)
      state.alert = AlertState {
        TextState("Error")
      } actions: {
        ButtonState {
          TextState("OK")
        }
      } message: {
        TextState(error.localizedDescription)
      }
      return .none
      
    case let .createUserResponse(.success(data)):
      print(data)
      state.isActivityIndicatorVisible = false
      return .none
      
    case let .createUserResponse(.failure(error)):
      print(error)
      state.isActivityIndicatorVisible = false
      return .none
      
    case .alert(.presented(.confirmOkay)):
      return .run { _ in
        await dismiss()
      }
      
    case .nextFromPhoneNumberButtonTapped:
      return .run { send in
        async let next: Void = send(.delegate(.nextScreenFromPhoneNumber))
        async let request: Void = send(.verifyRequest)
        _ = await (next, request)
      }
      
    case .nextFromOneTimeCodeButtonTapped:
      return .run { send in
        await send(.signInRequest)
      }
      
    case .resendButtonTapped:
      return .run { send in
        await send(.verifyRequest)
      }

    default:
      return .none
    }
  }
}
