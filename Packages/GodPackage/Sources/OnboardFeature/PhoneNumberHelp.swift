import AnalyticsClient
import ComposableArchitecture
import Constants
import Styleguide
import SwiftUI

public struct PhoneNumberHelpLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    public init() {}
  }

  public enum Action: Equatable {
    case onTask
    case onAppear
    case okayButtonTapped
  }

  @Dependency(\.dismiss) var dismiss
  @Dependency(\.analytics) var analytics

  public var body: some Reducer<State, Action> {
    Reduce<State, Action> { _, action in
      switch action {
      case .onTask:
        return .none
      case .onAppear:
        analytics.logScreen(screenName: "PhoneNumberHelp", of: self)
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
        .font(.system(.body, design: .rounded, weight: .bold))

      Text("God cares intensely about your privacy.\nWe will not share your personal information with outside parties or use it for private purposes without your permission.", bundle: .module)
        .font(.system(.body, design: .rounded))

      Button {
        store.send(.okayButtonTapped)
      } label: {
        Text("OK", bundle: .module)
          .font(.system(.body, design: .rounded))
          .frame(height: 56)
          .frame(maxWidth: .infinity)
          .foregroundStyle(.white)
          .background(Color.godService)
          .clipShape(Capsule())
      }

      Link(destination: Constants.privacyPolicyURL) {
        Text("Privacy Policy", bundle: .module)
          .foregroundStyle(Color.godTextSecondaryLight)
          .font(.system(.body, design: .rounded))
      }
    }
    .padding(.horizontal, 24)
    .multilineTextAlignment(.center)
    .buttonStyle(HoldDownButtonStyle())
    .onAppear { store.send(.onAppear) }
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
