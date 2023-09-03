import StoreKit

public struct StoreKitClient {
  public var godModeDefault: @Sendable () -> String
  public var transactionUpdates: @Sendable () -> Transaction.Transactions
  public var products: @Sendable ([String]) async throws -> [Product]
  public var purchase: @Sendable (Product) async throws -> Product.PurchaseResult
}
