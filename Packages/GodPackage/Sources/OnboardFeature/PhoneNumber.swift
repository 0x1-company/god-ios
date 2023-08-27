import Colors
import ComposableArchitecture
import FirebaseAuthClient
import PhoneNumberClient
import PhoneNumberKit
import SwiftUI

public struct PhoneNumberReducer: Reducer {
  public struct State: Equatable {
    var phoneNumber = ""
    public init() {}
  }
  
  public enum Action: Equatable {
    case nextButtonTapped
    case changePhoneNumber(String)
    case delegate(Delegate)
    
    public enum Delegate: Equatable {
      case nextScreen
      case changePhoneNumber(String)
    }
  }
  
  public func reduce(into state: inout State, action: Action) -> Effect<Action> {
    switch action {
    case .nextButtonTapped:
      return .run { send in
        await send(.delegate(.nextScreen))
      }
    case let .changePhoneNumber(number):
      state.phoneNumber = number
      return .run { send in
        await send(.delegate(.changePhoneNumber(number)))
      }
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
