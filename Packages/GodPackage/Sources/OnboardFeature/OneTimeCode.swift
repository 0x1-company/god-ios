import ComposableArchitecture
import SwiftUI

public struct OneTimeCodeReducer: Reducer {
  public init() {}

  public struct State: Equatable {
    public init() {}
  }

  public enum Action: Equatable {
    case onTask
    case nextButtonTapped
    case delegate(Delegate)

    public enum Delegate: Equatable {
      case nextFirstNameSetting
    }
  }

  public var body: some ReducerOf<Self> {
    Reduce { _, action in
      switch action {
      case .onTask:
        return .none

      case .nextButtonTapped:
        return .run { send in
          await send(.delegate(.nextFirstNameSetting))
        }

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

          TextField("Code", text: .constant(""))
            .font(.title)
            .textContentType(.telephoneNumber)
            .textContentType(.oneTimeCode)

          Spacer()

          VStack(spacing: 24) {
            Button("Resend in 30") {}
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
        initialState: OneTimeCodeReducer.State(),
        reducer: { OneTimeCodeReducer() }
      )
    )
  }
}
