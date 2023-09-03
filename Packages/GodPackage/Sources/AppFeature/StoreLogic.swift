import ComposableArchitecture
import StoreKitClient

public struct StoreLogic: Reducer {
  @Dependency(\.store) var storeClient

  public func reduce(
    into state: inout AppReducer.State,
    action: AppReducer.Action
  ) -> Effect<AppReducer.Action> {
    switch action {
    case .appDelegate(.delegate(.didFinishLaunching)):
      enum Cancel { case id }
      return .run(priority: .background) { send in
        for await result in storeClient.transactionUpdates() {
          guard case let .verified(transaction) = result
          else { continue }
//          if transaction.revocationDate != nil {
//            // 払い戻しされてるので特典削除
//          }
//          if let expiretionDate = transaction.expirationDate,
//             Date.now < expiretionDate &&
//              !transaction.isUpgraded
//          {
//            // 有効なサブスクなのでproductIdに対応した特典を有効にする
//          }
          await transaction.finish()
        }
      }
      .cancellable(id: Cancel.id)

    default:
      return .none
    }
  }
}
