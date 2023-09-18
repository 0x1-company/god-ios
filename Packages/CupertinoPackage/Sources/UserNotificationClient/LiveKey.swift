import Combine
import ComposableArchitecture
import UserNotifications

extension UserNotificationClient: DependencyKey {
  public static let liveValue = Self(
    notificationSettings: {
      await withCheckedContinuation { continuation in
        UNUserNotificationCenter.current().getNotificationSettings { settings in
          continuation.resume(returning: settings.authorizationStatus)
        }
      }
    },
    requestAuthorization: {
      try await UNUserNotificationCenter.current().requestAuthorization(options: $0)
    }
  )
}
