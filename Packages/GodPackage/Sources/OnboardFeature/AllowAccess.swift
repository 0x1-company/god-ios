import AnalyticsClient
import ComposableArchitecture
import ContactsClient
import Styleguide
import SwiftUI
import UserNotificationClient

@Reducer
public struct AllowAccessLogic {
  public init() {}

  public struct State: Equatable {
    var isDisabledContact = false
    var isDisabledNotify = false
    public init() {}
  }

  public enum Action: Equatable {
    case onTask
    case onAppear
  }

  @Dependency(\.contacts) var contacts
  @Dependency(\.analytics) var analytics
  @Dependency(\.userNotifications) var userNotifications

  public var body: some Reducer<State, Action> {
    Reduce<State, Action> { _, action in
      switch action {
      case .onTask:
        return .none

      case .onAppear:
        analytics.logScreen(screenName: "AllowAccess", of: self)
        return .none
      }
    }
  }
}

public struct AllowAccessView: View {
  let store: StoreOf<AllowAccessLogic>

  public init(store: StoreOf<AllowAccessLogic>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      VStack {
        Spacer()

        VStack(spacing: 24) {
          Image(ImageResource.godIconWhite)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 140)

          Text("God needs to find your school and suggest friends.", bundle: .module)
            .font(.system(.body, design: .rounded))
        }

        Spacer()

        VStack(spacing: 8) {
          Button {} label: {
            HStack(spacing: 12) {
              Image(ImageResource.bell)
                .resizable()
                .aspectRatio(1, contentMode: .fit)
                .frame(width: 24, height: 24)
              Text("Enable Notify")
            }
          }
          .disabled(viewStore.isDisabledNotify)
          .buttonStyle(AllowButtonStyle(isDisabled: viewStore.isDisabledNotify))

          Button {} label: {
            HStack(spacing: 12) {
              Image(ImageResource.ledger)
                .resizable()
                .aspectRatio(1, contentMode: .fit)
                .frame(width: 24, height: 24)
              Text("Enable Contacts")
            }
          }
          .disabled(viewStore.isDisabledContact)
          .buttonStyle(AllowButtonStyle(isDisabled: viewStore.isDisabledContact))
        }

        Spacer()

        Spacer()

        HStack(spacing: 8) {
          Image(systemName: "lock.fill")
            .tint(Color.white)

          Text("God cares intensely about your privacy.\nWe will never text or spam your contacts.", bundle: .module)
            .multilineTextAlignment(.leading)
        }
        .font(.system(.callout, design: .rounded))
      }
      .padding(.horizontal, 24)
      .foregroundStyle(Color.white)
      .background(Color.godService)
      .multilineTextAlignment(.center)
      .navigationTitle(Text("Please allow access", bundle: .module))
      .navigationBarTitleDisplayMode(.inline)
      .toolbarBackground(Color.godService, for: .navigationBar)
      .toolbarBackground(.visible, for: .navigationBar)
      .toolbarColorScheme(.dark, for: .navigationBar)
      .task { await store.send(.onTask).finish() }
      .onAppear { store.send(.onAppear) }
    }
  }

  struct AllowButtonStyle: ButtonStyle {
    let isDisabled: Bool
    func makeBody(configuration: Configuration) -> some View {
      configuration.label
        .font(.system(.body, design: .rounded, weight: .bold))
        .frame(height: 54)
        .frame(maxWidth: .infinity)
        .foregroundStyle(isDisabled ? Color.white : Color.black)
        .background(isDisabled ? Color.godService : Color.white)
        .clipShape(Capsule())
        .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
        .animation(.default, value: configuration.isPressed)
        .overlay {
          if isDisabled {
            RoundedRectangle(cornerRadius: 54 / 2)
              .stroke(Color.white, lineWidth: 1)
          }
        }
        .opacity(isDisabled ? 0.3 : 1.0)
    }
  }
}

#Preview {
  NavigationStack {
    AllowAccessView(
      store: .init(
        initialState: AllowAccessLogic.State(),
        reducer: { AllowAccessLogic() }
      )
    )
  }
}
