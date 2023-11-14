import ComposableArchitecture
import SwiftUI
import UIApplicationClient

@Reducer
public struct NotificationsReEnableLogic {
  public init() {}

  public struct State: Equatable {
    public init() {}
  }

  public enum Action: Equatable {
    case onTapGesture
  }

  @Dependency(\.openURL) var openURL
  @Dependency(\.application.openNotificationSettingsURLString) var openNotificationSettingsURLString

  public var body: some Reducer<State, Action> {
    Reduce<State, Action> { _, action in
      switch action {
      case .onTapGesture:
        return .run { _ in
          let openNotificationSettingsURLString = await openNotificationSettingsURLString()
          guard let url = URL(string: openNotificationSettingsURLString) else { return }
          await openURL(url)
        }
      }
    }
  }
}

public struct NotificationsReEnableView: View {
  let store: StoreOf<NotificationsReEnableLogic>

  public init(store: StoreOf<NotificationsReEnableLogic>) {
    self.store = store
  }

  public var body: some View {
    VStack(spacing: 0) {
      HStack(spacing: 16) {
        Image(systemName: "bell.slash.fill")
          .font(.system(size: 30))
        VStack(alignment: .leading, spacing: 4) {
          Text("Notifications are off", bundle: .module)
            .font(.system(.body, design: .rounded, weight: .bold))
          Text("Tap to re-enable", bundle: .module)
            .foregroundStyle(Color.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        Image(systemName: "chevron.right")
      }
      .frame(height: 70)
      .padding(.horizontal, 16)
      .foregroundStyle(.white)
      .background(Color.godService)
    }
    .onTapGesture {
      store.send(.onTapGesture)
    }
  }
}

#Preview {
  NotificationsReEnableView(
    store: .init(
      initialState: NotificationsReEnableLogic.State(),
      reducer: { NotificationsReEnableLogic() }
    )
  )
}
