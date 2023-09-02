import StoreKit

public struct StoreKitClient {
  public var addPayment: @Sendable (SKPayment) async -> Void
  public var appStoreReceiptURL: @Sendable () -> URL?
  public var isAuthorizedForPayments: @Sendable () -> Bool
  public var transactionUpdates: @Sendable () -> Transaction.Transactions
  public var products: @Sendable ([String]) async throws -> [Product]
  public var purchase: @Sendable (Product) async throws -> Product.PurchaseResult
}
