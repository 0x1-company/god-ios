import Colors
import ComposableArchitecture
import PhoneNumberKit
import SwiftUI

public struct PhoneNumberReducer: Reducer {
  public init() {}

  public struct State: Equatable {
    public init() {}
  }

  public enum Action: Equatable {
    case onTask
    case nextButtonTapped
    case delegate(Delegate)

    public enum Delegate: Equatable {
      case nextOneTimeCode
    }
  }

  public var body: some ReducerOf<Self> {
    Reduce { _, action in
      switch action {
      case .onTask:
        return .none

      case .nextButtonTapped:
        return .run { send in
          await send(.delegate(.nextOneTimeCode))
        }

      case .delegate:
        return .none
      }
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
        Color.god.service
          .ignoresSafeArea()

        VStack(spacing: 12) {
          Spacer()
          Text("Enter your phone Number")
            .bold()
            .font(.title3)

          TextField("Phone Number", text: .constant(""))
            .font(.title)
            .textContentType(.telephoneNumber)

          Text("Remember - never sign up\nwith another person's phone number.")
            .multilineTextAlignment(.center)

          Spacer()

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
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .foregroundColor(Color.white)
        .multilineTextAlignment(.center)
      }
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
