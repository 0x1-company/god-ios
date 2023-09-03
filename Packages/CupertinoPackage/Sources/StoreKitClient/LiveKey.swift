import Dependencies
import StoreKit

extension StoreKitClient: DependencyKey {
  public static let liveValue = Self(
    godModeDefault: { "jp.godapp.ios.staging.god_mode.default" },
    addPayment: { SKPaymentQueue.default().add($0) },
    appStoreReceiptURL: { Bundle.main.appStoreReceiptURL },
    isAuthorizedForPayments: { SKPaymentQueue.canMakePayments() },
    transactionUpdates: { Transaction.updates },
    products: { try await Product.products(for: $0) },
    purchase: { try await $0.purchase() }
  )
}
