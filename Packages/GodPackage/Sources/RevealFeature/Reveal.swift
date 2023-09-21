import ButtonStyles
import Colors
import ComposableArchitecture
import God
import GodClient
import StoreKit
import StoreKitClient
import SwiftUI

public struct RevealLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    var isActivityIndicatorVisible = false
    var currentUser: God.CurrentUserQuery.Data.CurrentUser?
    public init() {}
  }

  public enum Action: Equatable {
    case onTask
    case seeFullNameButtonTapped
    case purchaseError(Product.PurchaseError)
    case verificationResponse(VerificationResult<StoreKit.Transaction>)
    case pendingResponse
    case userCancelledResponse
    case currentUserResponse(TaskResult<God.CurrentUserQuery.Data>)
  }

  @Dependency(\.store) var storeClient
  @Dependency(\.godClient) var godClient

  enum Cancel {
    case id
    case currentUser
  }

  public var body: some Reducer<State, Action> {
    Reduce<State, Action> { state, action in
      switch action {
      case .onTask:
        return .run { send in
          for try await data in godClient.currentUser() {
            await send(.currentUserResponse(.success(data)))
          }
        } catch: { error, send in
          await send(.currentUserResponse(.failure(error)))
        }
        .cancellable(id: Cancel.currentUser, cancelInFlight: true)

      case .seeFullNameButtonTapped:
        guard let userId = state.currentUser?.id else { return .none }
        let token = UUID(uuidString: userId)!
        state.isActivityIndicatorVisible = true
        let id = storeClient.revealId()
        return .run { send in
          let products = try await storeClient.products([id])
          guard let product = products.first(where: { $0.id == id })
          else { return }
          let result = try await storeClient.purchase(product, token)
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
          print(error)
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
        state.isActivityIndicatorVisible = false
        /// transaction.idをserverに送って課金処理を行う
        return .run { _ in
          await transaction.finish()
        }
      case let .verificationResponse(.unverified(transaction, error)):
        state.isActivityIndicatorVisible = false
        print(transaction)
        print(error)
        return .none
      case .pendingResponse:
        state.isActivityIndicatorVisible = false
        return .none
      case .userCancelledResponse:
        state.isActivityIndicatorVisible = false
        return .none

      case let .currentUserResponse(.success(data)):
        state.currentUser = data.currentUser
        return .none

      case .currentUserResponse(.failure):
        return .none
      }
    }
  }
}

public struct RevealView: View {
  let store: StoreOf<RevealLogic>

  public init(store: StoreOf<RevealLogic>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      VStack(spacing: 16) {
        VStack(spacing: 16) {
          Text("The first letter in their name is...", bundle: .module)
            .font(.title3)
            .bold()

          Text("S")
            .font(.largeTitle)
            .bold()
            .foregroundColor(Color.godService)
        }
        VStack {
          Button {
            viewStore.send(.seeFullNameButtonTapped)
          } label: {
            Text("See Full Name", bundle: .module)
              .bold()
              .frame(height: 56)
              .frame(maxWidth: .infinity)
              .foregroundColor(.white)
              .background(Color.godService)
              .clipShape(Capsule())
          }
          .buttonStyle(HoldDownButtonStyle())

          Text("You have 2 reveals", bundle: .module)
            .foregroundColor(.godTextSecondaryLight)
        }
      }
      .padding(.horizontal, 16)
      .multilineTextAlignment(.center)
      .task { await viewStore.send(.onTask).finish() }
    }
  }
}

struct RevealViewPreviews: PreviewProvider {
  static var previews: some View {
    RevealView(
      store: .init(
        initialState: RevealLogic.State(),
        reducer: { RevealLogic() }
      )
    )
  }
}
