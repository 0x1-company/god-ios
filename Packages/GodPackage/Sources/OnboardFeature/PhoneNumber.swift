import Colors
import ComposableArchitecture
import FirebaseAuthClient
import PhoneNumberClient
import PhoneNumberKit
import SwiftUI
import UserDefaultsClient

public struct PhoneNumberLogic: Reducer {
  public struct State: Equatable {
    @BindingState var phoneNumber = ""
    var isDisabled = true
    var isActivityIndicatorVisible = false
    @PresentationState var alert: AlertState<Action.Alert>?
    public init() {}
  }

  public enum Action: Equatable, BindableAction {
    case nextButtonTapped
    case binding(BindingAction<State>)
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

  @Dependency(\.userDefaults) var userDefaults
  @Dependency(\.phoneNumberClient) var phoneNumberClient
  @Dependency(\.firebaseAuth.verifyPhoneNumber) var verifyPhoneNumber

  public var body: some Reducer<State, Action> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .nextButtonTapped:
        guard phoneNumberClient.isValidPhoneNumber(state.phoneNumber)
        else { return .none }
        state.isActivityIndicatorVisible = true
        return .run { [state] send in
          await userDefaults.setPhoneNumber(state.phoneNumber)
          let format = try phoneNumberClient.parseFormat(state.phoneNumber)
          await send(
            .verifyResponse(
              TaskResult {
                try await verifyPhoneNumber(format)
              }
            )
          )
        }
      case .binding:
        state.isDisabled = !phoneNumberClient.isValidPhoneNumber(state.phoneNumber)
        return .none
      case let .verifyResponse(.success(id)):
        state.isActivityIndicatorVisible = false
        return .run { send in
          await userDefaults.setVerificationId(id ?? "")
          await send(.delegate(.nextScreen), animation: .default)
        }
      case let .verifyResponse(.failure(error)):
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

      case .alert(.presented(.confirmOkay)):
        return .none

      case .alert:
        return .none

      case .delegate:
        return .none
      }
    }
  }
}

public struct PhoneNumberView: View {
  let store: StoreOf<PhoneNumberLogic>
  @FocusState var focus: Bool

  public init(store: StoreOf<PhoneNumberLogic>) {
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

          TextField("Phone Number", text: viewStore.$phoneNumber)
          .font(.title)
          .textContentType(.telephoneNumber)
          .keyboardType(.phonePad)
          .focused($focus)

          Text("Remember - never sign up\nwith another person's phone number.")
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
        .padding(.vertical, 16)
        .foregroundColor(Color.godWhite)
        .multilineTextAlignment(.center)
      }
      .navigationBarBackButtonHidden()
      .onAppear {
        focus = true
      }
    }
  }
}

struct PhoneNumberViewPreviews: PreviewProvider {
  static var previews: some View {
    PhoneNumberView(
      store: .init(
        initialState: PhoneNumberLogic.State(),
        reducer: { PhoneNumberLogic() }
      )
    )
  }
}
