import Dependencies
import XCTestDynamicOverlay

public extension DependencyValues {
  var deleteAccountReasons: DeleteAccountReasonClient {
    get { self[DeleteAccountReasonClient.self] }
    set { self[DeleteAccountReasonClient.self] = newValue }
  }
}

extension DeleteAccountReasonClient: TestDependencyKey {
  public static let testValue = Self(
    insert: unimplemented("\(Self.self).insert")
  )
}
