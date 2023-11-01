import Contacts
import UserNotifications

public struct UserSettingsClient {
  public var update: (UpdateParam) async throws -> Void

  public struct UpdateParam: Equatable {
    let uid: String
    let contactStatus: String
    let notificationStatus: String

    public init(
      uid: String,
      contact: CNAuthorizationStatus,
      notification: UNAuthorizationStatus
    ) {
      self.uid = uid
      contactStatus = contact.stringValue
      notificationStatus = notification.stringValue
    }
  }
}

extension CNAuthorizationStatus {
  var stringValue: String {
    switch self {
    case .notDetermined:
      return "notDetermined"
    case .restricted:
      return "restricted"
    case .denied:
      return "denied"
    case .authorized:
      return "authorized"
    @unknown default:
      fatalError()
    }
  }
}

extension UNAuthorizationStatus {
  var stringValue: String {
    switch self {
    case .notDetermined:
      return "notDetermined"
    case .denied:
      return "denied"
    case .authorized:
      return "authorized"
    case .provisional:
      return "provisional"
    case .ephemeral:
      return "ephemeral"
    @unknown default:
      fatalError()
    }
  }
}
