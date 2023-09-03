import Dependencies
import XCTestDynamicOverlay

public extension DependencyValues {
  var store: StoreKitClient {
    get { self[StoreKitClient.self] }
    set { self[StoreKitClient.self] = newValue }
  }
}

extension StoreKitClient: TestDependencyKey {
  public static let testValue = Self(
    godModeDefault: unimplemented("\(Self.self).godModeDefault"),
    addPayment: unimplemented("\(Self.self).addPayment"),
    appStoreReceiptURL: unimplemented("\(Self.self).appStoreReceiptURL", placeholder: nil),
    isAuthorizedForPayments: unimplemented(
      "\(Self.self).isAuthorizedForPayments", placeholder: false
    ),
    transactionUpdates: unimplemented("\(Self.self).transactionUpdates"),
    products: unimplemented("\(Self.self).products"),
    purchase: unimplemented("\(Self.self).purchase")
  )
}
