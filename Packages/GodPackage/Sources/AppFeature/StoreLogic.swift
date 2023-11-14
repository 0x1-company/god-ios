import ComposableArchitecture
import God
import GodClient
import StoreKitClient
import StoreKitHelpers

@Reducer
public struct StoreLogic {
  @Dependency(\.store) var storeClient
  @Dependency(\.godClient) var godClient

  public func reduce(
    into state: inout AppLogic.State,
    action: AppLogic.Action
  ) -> Effect<AppLogic.Action> {
    switch action {
    case .appDelegate(.delegate(.didFinishLaunching)):
      enum Cancel { case id }
      return .run(priority: .background) { send in
        for await result in storeClient.transactionUpdates() {
          await send(.transaction(TaskResult {
            try checkVerified(result)
          }))
        }
      } catch: { error, send in
        await send(.transaction(.failure(error)))
      }
      .cancellable(id: Cancel.id)

    case let .transaction(.success(transaction)):
      return .run { send in
        _ = try await godClient.createTransaction(transaction.id.description)
        await send(.createTransactionResponse(.success(transaction)))
      } catch: { error, send in
        await send(.createTransactionResponse(.failure(error)))
      }

    case let .createTransactionResponse(.success(transaction)):
      return .run { _ in
        await transaction.finish()
      }

    default:
      return .none
    }
  }
}
