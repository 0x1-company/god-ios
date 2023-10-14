import Contacts
import UserNotifications

public struct UserSettingsClient {
  public var contact: (ContactParam) async throws -> Void
  public var notification: (NotificationParam) async throws -> Void
  
  public struct ContactParam: Codable, Equatable {
    let uid: String
    let status: AuthorizationStatus
    
    public enum AuthorizationStatus: String, Codable {
      case notDetermined
      case restricted
      case denied
      case authorized
    }
    
    public init(uid: String, status: CNAuthorizationStatus) {
      self.uid = uid
      switch status {
      case .notDetermined:
        self.status = .notDetermined
      case .restricted:
        self.status = .restricted
      case .denied:
        self.status = .denied
      case .authorized:
        self.status = .authorized
      @unknown default:
        fatalError()
      }
    }
  }
  
  public struct NotificationParam: Codable, Equatable {
    let uid: String
    let status: AuthorizationStatus
    
    public enum AuthorizationStatus: String, Codable {
      case notDetermined
      case denied
      case authorized
      case provisional
      case ephemeral
    }
    
    public init(uid: String, status: UNAuthorizationStatus) {
      self.uid = uid
      switch status {
      case .notDetermined:
        self.status = .notDetermined
      case .denied:
        self.status = .denied
      case .authorized:
        self.status = .authorized
      case .provisional:
        self.status = .provisional
      case .ephemeral:
        self.status = .ephemeral
      @unknown default:
        fatalError()
      }
    }
  }
}
