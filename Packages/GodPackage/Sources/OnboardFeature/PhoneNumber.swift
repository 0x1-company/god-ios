import Colors
import UserDefaultsClient
import ComposableArchitecture
import FirebaseAuthClient
import PhoneNumberClient
import PhoneNumberKit
import SwiftUI

public struct PhoneNumberReducer: Reducer {
  public struct State: Equatable {
    var phoneNumber = ""
    @PresentationState var alert: AlertState<Action.Alert>?
    public init() {}
  }
  
  public enum Action: Equatable {
    case nextButtonTapped
    case changePhoneNumber(String)
    case verifyResponse(TaskResult<String?>)
    case alert(PresentationAction<Alert>)
    case delegate(Delegate)
    
    public enum Delegate: Equatable {
      case nextScreen
    }
    
    public enum Alert: Equatable {
      case confirmOkay
    }
  }
  
  @Dependency(\.userDefaults) var userDefaultsClient
  @Dependency(\.phoneNumberClient) var phoneNumberClient
  @Dependency(\.firebaseAuth.verifyPhoneNumber) var verifyPhoneNumber
  
  public func reduce(into state: inout State, action: Action) -> Effect<Action> {
    switch action {
    case .nextButtonTapped:
      return .run { [state] send in
        async let next: Void = send(.delegate(.nextScreen), animation: .default)
        
        let format = try phoneNumberClient.parseFormat(state.phoneNumber)
        async let save: Void = await userDefaultsClient.setString(format, "format-phone-number")
        async let verify: Void = await send(
          .verifyResponse(
            TaskResult {
              try await verifyPhoneNumber(format)
            }
          )
        )
        _ = await (next, save, verify)
      }
    case let .changePhoneNumber(number):
      state.phoneNumber = number
      return .none
      
    case let .verifyResponse(.success(id)):
      let verifyId = id ?? ""
      return .run { _ in
        await userDefaultsClient.setString(verifyId, "verify-id")
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
      
    case .alert(.presented(.confirmOkay)):
      return .none
      
    case .alert:
      return .none

    case .delegate:
      return .none
    }
  }
}

public struct PhoneNumberView: View {
  let store: StoreOf<PhoneNumberReducer>

  public init(store: StoreOf<PhoneNumberReducer>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      ZStack {
        Color.godService
          .ignoresSafeArea()

        VStack(spacing: 12) {
          Spacer()
          Text("Enter your phone Number")
            .bold()
            .font(.title3)

          TextField(
            "Phone Number",
            text: viewStore.binding(
              get: \.phoneNumber,
              send: PhoneNumberReducer.Action.changePhoneNumber
            )
          )
          .font(.title)
          .textContentType(.telephoneNumber)
          .keyboardType(.phonePad)

          Text("Remember - never sign up\nwith another person's phone number.")
            .multilineTextAlignment(.center)

          Spacer()

          NextButton(
            isLoading: false,
            isDisabled: false
          ) {
            viewStore.send(.nextButtonTapped)
          }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .foregroundColor(Color.white)
        .multilineTextAlignment(.center)
      }
      .navigationBarBackButtonHidden()
    }
  }
}

struct PhoneNumberViewPreviews: PreviewProvider {
  static var previews: some View {
    PhoneNumberView(
      store: .init(
        initialState: PhoneNumberReducer.State(),
        reducer: { PhoneNumberReducer() }
      )
    )
  }
}
