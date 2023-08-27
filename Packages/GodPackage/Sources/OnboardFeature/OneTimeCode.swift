import ComposableArchitecture
import FirebaseAuth
import FirebaseAuthClient
import SwiftUI

public struct OneTimeCodeView: View {
  let store: StoreOf<PhoneNumberAuthReducer>

  public init(store: StoreOf<PhoneNumberAuthReducer>) {
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
              send: PhoneNumberAuthReducer.Action.changeOneTimeCode
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
              viewStore.send(.nextFromOneTimeCodeButtonTapped)
            }
          }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .foregroundColor(Color.white)
        .multilineTextAlignment(.center)
      }
      .alert(store: store.scope(state: \.$alert, action: PhoneNumberAuthReducer.Action.alert))
    }
  }
}

struct OneTimeCodeViewPreviews: PreviewProvider {
  static var previews: some View {
    OneTimeCodeView(
      store: .init(
        initialState: PhoneNumberAuthReducer.State(),
        reducer: { PhoneNumberAuthReducer() }
      )
    )
  }
}
