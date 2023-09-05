import Dependencies
import StoreKit

extension StoreKitClient: DependencyKey {
  public static let liveValue = Self(
    godModeId: { "jp.godapp.ios.staging.god_mode.default" },
    revealId: { "jp.godapp.ios.staging.reveal_poll" },
    transactionUpdates: { Transaction.updates },
    products: { try await Product.products(for: $0) },
    purchase: { try await $0.purchase() }
  )
}
