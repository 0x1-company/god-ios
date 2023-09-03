import StoreKit

public struct StoreKitClient {
  public var godModeDefault: @Sendable () -> String
  public var transactionUpdates: @Sendable () -> Transaction.Transactions
  public var products: @Sendable ([String]) async throws -> [Product]
  public var purchase: @Sendable (Product) async throws -> Product.PurchaseResult
}

extension StoreKitClient {
  public func purchase(product: Product) async throws -> Transaction {
    let result = try await product.purchase()
    switch result {
    case let .success(.verified(transaction)):
      return transaction
    case let .success(.unverified(_, error)):
      throw error
    case .userCancelled:
      throw PurchaseError.userCancelled
    case .pending:
      throw PurchaseError.pending
    @unknown default:
      fatalError()
    }
  }
}

extension StoreKitClient {
  public enum PurchaseError: Error {
    case userCancelled
    case pending
  }
}
