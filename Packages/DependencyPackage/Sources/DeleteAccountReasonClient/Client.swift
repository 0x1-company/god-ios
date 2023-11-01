import Contacts
import UserNotifications

public struct DeleteAccountReasonClient {
  public var insert: (InsertParam) async throws -> Void

  public struct InsertParam: Equatable {
    let uid: String
    let reasons: [String]

    public init(uid: String, reasons: [String]) {
      self.uid = uid
      self.reasons = reasons
    }
  }
}
