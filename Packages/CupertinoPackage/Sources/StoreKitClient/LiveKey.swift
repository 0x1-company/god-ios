import Dependencies
import StoreKit

extension StoreKitClient: DependencyKey {
  public static let liveValue = Self(
    godModeDefault: { "jp.godapp.ios.staging.god_mode.default" },
    transactionUpdates: { Transaction.updates },
    products: { try await Product.products(for: $0) },
    purchase: { try await $0.purchase() }
  )
}
