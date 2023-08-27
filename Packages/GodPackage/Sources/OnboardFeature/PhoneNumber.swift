import Colors
import ComposableArchitecture
import FirebaseAuthClient
import PhoneNumberClient
import PhoneNumberKit
import SwiftUI

public struct PhoneNumberView: View {
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
          Text("Enter your phone Number")
            .bold()
            .font(.title3)

          TextField(
            "Phone Number",
            text: viewStore.binding(
              get: \.phoneNumber,
              send: PhoneNumberAuthReducer.Action.changePhoneNumber
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
            viewStore.send(.nextFromPhoneNumberButtonTapped)
          }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .foregroundColor(Color.white)
        .multilineTextAlignment(.center)
      }
      .navigationBarBackButtonHidden()
      .alert(store: store.scope(state: \.$alert, action: PhoneNumberAuthReducer.Action.alert))
    }
  }
}

struct PhoneNumberViewPreviews: PreviewProvider {
  static var previews: some View {
    PhoneNumberView(
      store: .init(
        initialState: PhoneNumberAuthReducer.State(),
        reducer: { PhoneNumberAuthReducer() }
      )
    )
  }
}
