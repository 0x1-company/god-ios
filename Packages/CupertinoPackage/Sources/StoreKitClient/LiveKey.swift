import Dependencies
import StoreKit

extension StoreKitClient: DependencyKey {
  public static let liveValue = Self(
    godModeId: { "jp.godapp.ios.staging.god_mode.default" },
    revealId: { "jp.godapp.ios.staging.reveal_poll" },
    transactionUpdates: { Transaction.updates },
    products: { try await Product.products(for: $0) },
    purchase: { product, token in
      try await product.purchase(options: [.appAccountToken(token)])
    }
  )
}
