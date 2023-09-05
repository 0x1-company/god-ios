import ButtonStyles
import Colors
import ComposableArchitecture
import StoreKit
import StoreKitClient
import SwiftUI

public struct GodModeLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    var product: Product
    public init(product: Product) {
      self.product = product
    }
  }

  public enum Action: Equatable {
    case onTask
    case maybeLaterButtonTapped
    case continueButtonTapped
    case purchaseError(Product.PurchaseError)
    case verificationResponse(VerificationResult<StoreKit.Transaction>)
    case pendingResponse
    case userCancelledResponse
    case delegate(Delegate)

    public enum Delegate: Equatable {
      case activated
    }
  }

  @Dependency(\.dismiss) var dismiss
  @Dependency(\.store) var storeClient

  public var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .onTask:
        return .none
      case .maybeLaterButtonTapped:
        return .run { _ in
          await dismiss()
        }
      case .continueButtonTapped:
        enum Cancel { case id }
        return .run { [state] send in
          let result = try await storeClient.purchase(state.product)
          switch result {
          case let .success(verificationResult):
            await send(.verificationResponse(verificationResult))
          case .pending:
            await send(.pendingResponse)
          case .userCancelled:
            await send(.userCancelledResponse)
          @unknown default:
            fatalError()
          }
        } catch: { error, send in
          guard let purchaseError = error as? Product.PurchaseError
          else { return }
          await send(.purchaseError(purchaseError))
        }
        .cancellable(id: Cancel.id)
      case let .purchaseError(error):
        switch error {
        case .invalidQuantity:
          return .none
        case .productUnavailable:
          return .none
        case .purchaseNotAllowed:
          return .none
        case .ineligibleForOffer:
          return .none
        case .invalidOfferIdentifier:
          return .none
        case .invalidOfferPrice:
          return .none
        case .invalidOfferSignature:
          return .none
        case .missingOfferParameters:
          return .none
        @unknown default:
          return .none
        }
      case let .verificationResponse(.verified(transaction)):
        /// transaction.idをserverに送って課金処理を行う
        return .run { send in
          await transaction.finish()
          await send(.delegate(.activated), animation: .default)
          await dismiss()
        }
      case let .verificationResponse(.unverified(transaction, error)):
        print(transaction)
        print(error)
        return .none
      case .pendingResponse:
        return .none
      case .userCancelledResponse:
        return .none
      case .delegate:
        return .none
      }
    }
  }
}

public struct GodModeView: View {
  let store: StoreOf<GodModeLogic>

  public init(store: StoreOf<GodModeLogic>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      VStack(spacing: 24) {
        VStack(spacing: 0) {
          Text("定期課金。いつでもキャンセルできます。")
          Text("お支払いはiTunesアカウントに請求され、iTunes Storeの設定でキャンセルするまで、購読は週[金額]円で自動更新されます。ロック解除をタップすると、利用規約と自動更新に同意したことになります。")
        }
        .font(.caption)
        .padding(.horizontal, 24)
        .foregroundColor(Color.gray)
        .multilineTextAlignment(.center)

        VStack(spacing: 16) {
          Image("see-who-likes-you", bundle: .module)
            .resizable()
            .scaledToFit()
            .padding(.horizontal, 60)

          GodModeFunctions()

          Text("\(viewStore.product.displayPrice)/week")

          Button {
            store.send(.continueButtonTapped)
          } label: {
            Text("Continue")
              .bold()
              .frame(height: 56)
              .frame(maxWidth: .infinity)
              .foregroundColor(Color.white)
              .background(Color.orange.gradient)
              .clipShape(Capsule())
              .padding(.horizontal, 60)
          }
          .buttonStyle(HoldDownButtonStyle())

          Button {
            store.send(.maybeLaterButtonTapped)
          } label: {
            Text("Maybe Later")
              .foregroundColor(Color.gray)
          }
          .buttonStyle(HoldDownButtonStyle())
        }
        .foregroundColor(Color.white)
        .padding(.vertical, 24)
        .background(Color.black.gradient)
        .cornerRadius(32 / 2)
        .overlay(
          RoundedRectangle(cornerRadius: 32 / 2)
            .stroke(Color.orange, lineWidth: 2)
        )
        .padding(.horizontal, 8)

        Spacer()
      }
      .background(Color.godBlack)
    }
  }
}

// struct GodModeViewPreviews: PreviewProvider {
//  static var previews: some View {
//    GodModeView(
//      store: .init(
//        initialState: GodModeLogic.State(
//          product: Product.
//        ),
//        reducer: { GodModeLogic() }
//      )
//    )
//  }
// }
