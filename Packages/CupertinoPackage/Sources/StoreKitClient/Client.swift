import StoreKit

public struct StoreKitClient {
  public var godModeId: @Sendable () -> String
  public var revealId: @Sendable () -> String
  public var transactionUpdates: @Sendable () -> Transaction.Transactions
  public var products: @Sendable ([String]) async throws -> [Product]
  public var purchase: @Sendable (Product, UUID) async throws -> Product.PurchaseResult
}
