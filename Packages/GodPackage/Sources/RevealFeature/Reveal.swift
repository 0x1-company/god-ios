import ButtonStyles
import Colors
import ComposableArchitecture
import God
import GodClient
import StoreKit
import StoreKitClient
import StoreKitHelpers
import SwiftUI

public struct RevealLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    var activityId: String
    var isActivityIndicatorVisible = false
    var revealFullNameLimit = 0
    var product: StoreKit.Product?
    var currentUser: God.CurrentUserQuery.Data.CurrentUser?

    public init(activityId: String) {
      self.activityId = activityId
    }
  }

  public enum Action: Equatable {
    case onTask
    case seeFullNameButtonTapped
    case productsResponse(TaskResult<[StoreKit.Product]>)
    case purchaseResponse(TaskResult<StoreKit.Transaction>)
    case currentUserResponse(TaskResult<God.CurrentUserQuery.Data>)
    case revealFullNameLimitResponse(TaskResult<God.RevealFullNameLimitQuery.Data>)
    case revealFullNameResponse(TaskResult<God.RevealFullNameMutation.Data>)
    case transactionFinish(StoreKit.Transaction)
    case delegate(Delegate)

    public enum Delegate: Equatable {
      case fullName(String)
    }
  }

  @Dependency(\.store) var storeClient
  @Dependency(\.dismiss) var dismiss
  @Dependency(\.godClient) var godClient

  enum Cancel {
    case id
    case currentUser
  }

  public var body: some Reducer<State, Action> {
    Reduce<State, Action> { state, action in
      switch action {
      case .onTask:
        let id = storeClient.revealId()
        return .run { send in
          await withTaskGroup(of: Void.self) { group in
            group.addTask {
              await currentUserRequest(send: send)
            }
            group.addTask {
              await revealFullNameLimitRequest(send: send)
            }
            group.addTask {
              await send(.productsResponse(TaskResult {
                try await storeClient.products([id])
              }))
            }
          }
        }
        
      case let .productsResponse(.success(products)):
        let id = storeClient.revealId()
        state.product = products.first(where: { $0.id == id })
        return .none
        
      case .productsResponse(.failure):
        return .run { _ in
          await dismiss()
        }
        
      case .seeFullNameButtonTapped where state.revealFullNameLimit > 0:
        let input = God.RevealFullNameInput(activityId: state.activityId)
        return .run { send in
          await revealFullNameRequest(send: send, input: input)
        }

      case .seeFullNameButtonTapped:
        guard let userId = state.currentUser?.id else { return .none }
        guard let token = UUID(uuidString: userId) else { return .none }
        guard let product = state.product else { return .none }
        state.isActivityIndicatorVisible = true
        return .run { send in
          let result = try await storeClient.purchase(product, token)
          switch result {
          case let .success(verificationResult):
            await send(.purchaseResponse(TaskResult {
              try checkVerified(verificationResult)
            }))
          case .pending:
            await send(.purchaseResponse(.failure(InAppPurchaseError.pending)))
          case .userCancelled:
            await send(.purchaseResponse(.failure(InAppPurchaseError.userCancelled)))
          @unknown default:
            fatalError()
          }
        } catch: { error, send in
          await send(.purchaseResponse(.failure(error)))
        }
        .cancellable(id: Cancel.id)
        
      case let .purchaseResponse(.success(transaction)):
        state.isActivityIndicatorVisible = false
        return .run { send in
          let data = try await godClient.createTransaction(transaction.id.description)
          guard data.createTransaction else { return }
          await send(.transactionFinish(transaction))
        }

      case .purchaseResponse(.failure):
        state.isActivityIndicatorVisible = false
        return .none

      case let .transactionFinish(transaction):
        let input = God.RevealFullNameInput(activityId: state.activityId)
        return .run { send in
          await transaction.finish()
          await revealFullNameRequest(send: send, input: input)
        }

      case let .currentUserResponse(.success(data)):
        state.currentUser = data.currentUser
        return .none

      case let .revealFullNameLimitResponse(.success(data)):
        state.revealFullNameLimit = data.revealFullNameLimit
        return .none

      case let .revealFullNameResponse(.success(data)):
        guard let fullName = data.revealFullName?.ja
        else { return .none }
        return .send(.delegate(.fullName(fullName)), animation: .default)

      default:
        return .none
      }
    }
  }

  func currentUserRequest(send: Send<Action>) async {
    do {
      for try await data in godClient.currentUser() {
        await send(.currentUserResponse(.success(data)))
      }
    } catch {
      await send(.currentUserResponse(.failure(error)))
    }
  }

  func revealFullNameLimitRequest(send: Send<Action>) async {
    do {
      for try await data in godClient.revealFullNameLimit() {
        await send(.revealFullNameLimitResponse(.success(data)))
      }
    } catch {
      await send(.revealFullNameLimitResponse(.failure(error)))
    }
  }
  
  func revealFullNameRequest(send: Send<Action>, input: God.RevealFullNameInput) async {
    await send(.revealFullNameResponse(TaskResult {
      try await godClient.revealFullName(input)
    }))
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
            Group {
              if viewStore.isActivityIndicatorVisible {
                ProgressView()
                  .progressViewStyle(.circular)
              } else {
                Text("See Full Name", bundle: .module)
              }
            }
            .bold()
            .frame(height: 56)
            .frame(maxWidth: .infinity)
            .foregroundColor(.white)
            .background(Color.godService)
            .clipShape(Capsule())
          }
          .buttonStyle(HoldDownButtonStyle())

          Group {
            if viewStore.revealFullNameLimit > 0 {
              Text("You have \(viewStore.revealFullNameLimit) reveals", bundle: .module)
            } else if let product = viewStore.product {
              Text("\(product.displayPrice) per reveal", bundle: .module)
            }
          }
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
        initialState: RevealLogic.State(
          activityId: ""
        ),
        reducer: { RevealLogic() }
      )
    )
  }
}
