import ButtonStyles
import ComposableArchitecture
import Constants
import SwiftUI

public struct PhoneNumberHelpLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    public init() {}
  }

  public enum Action: Equatable {
    case onTask
    case okayButtonTapped
  }

  @Dependency(\.dismiss) var dismiss

  public var body: some Reducer<State, Action> {
    Reduce<State, Action> { _, action in
      switch action {
      case .onTask:
        return .none
      case .okayButtonTapped:
        return .run { _ in
          await dismiss()
        }
      }
    }
  }
}

public struct PhoneNumberHelpView: View {
  let store: StoreOf<PhoneNumberHelpLogic>

  public init(store: StoreOf<PhoneNumberHelpLogic>) {
    self.store = store
  }

  public var body: some View {
    VStack(spacing: 12) {
      Image(.seeNoEvilMonkey)
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: 64, height: 64)
        .cornerRadius(12)

      Text("Create an account.", bundle: .module)
        .bold()

      Text("God cares intensely about your privacy.\nWe will not share your personal information with outside parties or use it for private purposes without your permission.", bundle: .module)

      Button {
        store.send(.okayButtonTapped)
      } label: {
        Text("OK", bundle: .module)
          .frame(height: 56)
          .frame(maxWidth: .infinity)
          .foregroundColor(.white)
          .background(Color.godService)
          .clipShape(Capsule())
      }

      Link(destination: Constants.privacyPolicyURL) {
        Text("Privacy Policy", bundle: .module)
          .foregroundColor(.godTextSecondaryLight)
      }
    }
    .padding(.horizontal, 24)
    .multilineTextAlignment(.center)
    .buttonStyle(HoldDownButtonStyle())
  }
}

#Preview {
  PhoneNumberHelpView(
    store: .init(
      initialState: PhoneNumberHelpLogic.State(),
      reducer: { PhoneNumberHelpLogic() }
    )
  )
  .environment(\.locale, Locale(identifier: "ja_JP"))
}
