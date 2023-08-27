import ComposableArchitecture
import FirebaseAuth
import FirebaseAuthClient
import SwiftUI

public struct OneTimeCodeReducer: Reducer {
  public struct State: Equatable {
    var oneTimeCode = ""
    var isActivityIndicatorVisible = false

    public init() {}
  }
  
  public enum Action: Equatable {
    case resendButtonTapped
    case nextButtonTapped
    case changeOneTimeCode(String)
    case delegate(Delegate)
    
    public enum Delegate: Equatable {
      case changeOneTimeCode(String)
      case resend
      case send
    }
  }
  
  public func reduce(into state: inout State, action: Action) -> Effect<Action> {
    switch action {
    case .resendButtonTapped:
      return .run { send in
        await send(.changeOneTimeCode(""))
        await send(.delegate(.resend), animation: .default)
      }
    case .nextButtonTapped:
      return .send(.delegate(.send))

    case let .changeOneTimeCode(code):
      state.oneTimeCode = code
      return .send(.delegate(.changeOneTimeCode(code)))
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
