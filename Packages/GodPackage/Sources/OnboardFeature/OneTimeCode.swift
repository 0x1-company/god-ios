import ComposableArchitecture
import FirebaseAuth
import FirebaseAuthClient
import SwiftUI

public struct OneTimeCodeReducer: Reducer {
  public init() {}

  public struct State: Equatable {
    var oneTimeCode = ""
    let verifyID: String

    public init(verifyID: String) {
      self.verifyID = verifyID
    }
  }

  public enum Action: Equatable {
    case onTask
    case changeOneTimeCode(String)
    case resendButtonTapped
    case nextButtonTapped
    case signInResponse(TaskResult<AuthDataResult?>)
    case delegate(Delegate)

    public enum Delegate: Equatable {
      case nextFirstNameSetting
    }
  }

  @Dependency(\.firebaseAuth) var firebaseAuth

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .onTask:
        return .none

      case let .changeOneTimeCode(oneTimeCode):
        state.oneTimeCode = oneTimeCode
        return .none

      case .resendButtonTapped:
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
        return .none
      case .signInResponse(.success(.none)):
        print("sign in is null")
        return .none
      case let .signInResponse(.failure(error)):
        print(error)
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
