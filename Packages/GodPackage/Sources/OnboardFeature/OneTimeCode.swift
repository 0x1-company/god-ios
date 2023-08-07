import ComposableArchitecture
import FirebaseAuth
import FirebaseAuthClient
import SwiftUI

public struct OneTimeCodeReducer: Reducer {
  public init() {}

  public struct State: Equatable {
    var oneTimeCode = ""
    var verifyID: String
    @PresentationState var alert: AlertState<Action.Alert>?

    public init(verifyID: String) {
      self.verifyID = verifyID
    }
  }

  public enum Action: Equatable {
    case onTask
    case changeOneTimeCode(String)
    case resendButtonTapped
    case verifyResponse(TaskResult<String?>)
    case nextButtonTapped
    case signInResponse(TaskResult<AuthDataResult?>)
    case alert(PresentationAction<Alert>)
    case delegate(Delegate)
    
    public enum Alert: Equatable {
      case confirmOkay
    }

    public enum Delegate: Equatable {
      case nextFirstNameSetting
    }
  }

  @Dependency(\.firebaseAuth) var firebaseAuth
  @Dependency(\.dismiss) var dismiss

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .onTask:
        return .none

      case let .changeOneTimeCode(oneTimeCode):
        state.oneTimeCode = oneTimeCode
        return .none

      case .resendButtonTapped:
        let formatNumber = ""
        return .run { send in
          await send(
            .verifyResponse(
              TaskResult {
                try await firebaseAuth.verifyPhoneNumber(formatNumber)
              }
            )
          )
        }
      case let .verifyResponse(.success(.some(id))):
        state.verifyID = id
        return .none
        
      case .verifyResponse(.success(.none)):
        print("verify response is null")
        return .none

      case let .verifyResponse(.failure(error)):
        state.alert = AlertState {
          TextState("Error")
        } actions: {
          ButtonState(action: .confirmOkay) {
            TextState("OK")
          }
        } message: {
          TextState(error.localizedDescription)
        }
        return .none

      case .nextButtonTapped:
        let credential = firebaseAuth.credential(state.verifyID, state.oneTimeCode)
        return .run { send in
          await send(
            .signInResponse(
              TaskResult {
                try await firebaseAuth.signIn(credential)
              }
            )
          )
        }
      case let .signInResponse(.success(.some(result))):
        print(result)
        return .run { send in
          await send(.delegate(.nextFirstNameSetting))
        }
      case .signInResponse(.success(.none)):
        print("sign in is null")
        return .none
      case let .signInResponse(.failure(error)):
        state.alert = AlertState {
          TextState("Error")
        } actions: {
          ButtonState(action: .confirmOkay) {
            TextState("OK")
          }
        } message: {
          TextState(error.localizedDescription)
        }
        return .none
      case .alert(.presented(.confirmOkay)):
        return .run { _ in
          await self.dismiss()
        }
      case .alert:
        return .none
      case .delegate:
        return .none
      }
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
        Color.god.service
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

            Button {
              viewStore.send(.nextButtonTapped)
            } label: {
              Text("Next")
                .bold()
                .frame(height: 56)
                .frame(maxWidth: .infinity)
            }
            .foregroundColor(Color.god.textPrimary)
            .background(Color.white)
            .clipShape(Capsule())
          }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .foregroundColor(Color.white)
        .multilineTextAlignment(.center)
      }
    }
  }
}

struct OneTimeCodeViewPreviews: PreviewProvider {
  static var previews: some View {
    OneTimeCodeView(
      store: .init(
        initialState: OneTimeCodeReducer.State(verifyID: ""),
        reducer: { OneTimeCodeReducer() }
      )
    )
  }
}
