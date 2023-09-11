import ComposableArchitecture
import StoreKitClient
import StoreKitHelpers

public struct StoreLogic: Reducer {
  @Dependency(\.store) var storeClient

  public func reduce(
    into state: inout AppLogic.State,
    action: AppLogic.Action
  ) -> Effect<AppLogic.Action> {
    switch action {
    case .appDelegate(.delegate(.didFinishLaunching)):
      enum Cancel { case id }
      return .run(priority: .background) { _ in
        for await result in storeClient.transactionUpdates() {
          let transaction = try checkVerified(result)
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
