import AnalyticsClient
import ComposableArchitecture
import God
import GodClient
import SwiftUI

@Reducer
public struct ShopLogic {
  public init() {}

  public struct State: Equatable {
    @PresentationState var alert: AlertState<Action.Alert>?
    @PresentationState var pickFriend: PickFriendToAddYourNameTheirPollLogic.State?
    var coinBalance = 0
    var items: [God.StoreQuery.Data.Store.Item] = []
    public init() {}
  }

  public enum Action {
    case onTask
    case onAppear
    case storeResponse(TaskResult<God.StoreQuery.Data>)
    case purchaseButtonTapped(id: String)
    case purchaseResponse(TaskResult<God.PurchaseMutation.Data>)
    case closeButtonTapped
    case alert(PresentationAction<Alert>)
    case pickFriend(PresentationAction<PickFriendToAddYourNameTheirPollLogic.Action>)

    public enum Alert: Equatable {
      case confirmOkay
    }
  }

  @Dependency(\.dismiss) var dismiss
  @Dependency(\.godClient) var godClient
  @Dependency(\.analytics) var analytics

  enum Cancel {
    case store
  }

  public var body: some Reducer<State, Action> {
    Reduce<State, Action> { state, action in
      switch action {
      case .onTask:
        return .run { send in
          await storeRequest(send: send)
        }
        .cancellable(id: Cancel.store, cancelInFlight: true)

      case .onAppear:
        analytics.logScreen(screenName: "Shop", of: self)
        return .none

      case let .storeResponse(.success(data)):
        state.items = data.store.items
        state.coinBalance = data.currentUser.wallet?.coinBalance ?? 0
        return .none

      case .storeResponse(.failure):
        state.items = []
        state.coinBalance = 0
        return .none

      case let .purchaseButtonTapped(id):
        guard let item = state.items.first(where: { $0.id == id })
        else { return .none }
        guard state.coinBalance >= item.coinAmount else {
          state.alert = .insufficientFundsForCoin
          return .none
        }
        if case .putYourNameInYourCrushsPoll = item.itemType {
          state.pickFriend = .init()
          return .none
        }
        let input = God.PurchaseInput(
          coinAmount: item.coinAmount,
          storeItemId: item.id
        )
        return .run { send in
          await purchaseRequest(send: send, input: input)
        }
      case .purchaseResponse(.success):
        state.alert = .purchaseSuccess
        return .run { send in
          await storeRequest(send: send)
        }
        .cancellable(id: Cancel.store, cancelInFlight: true)

      case .purchaseResponse(.failure):
        return .none

      case .closeButtonTapped:
        return .run { _ in
          await dismiss()
        }

      case .alert(.presented(.confirmOkay)):
        state.alert = nil
        return .none

      case .alert:
        return .none

      case .pickFriend(.dismiss):
        state.pickFriend = nil
        return .none

      case let .pickFriend(.presented(.delegate(.purchase(userId)))):
        state.pickFriend = nil
        guard
          let crushPoll = state.items.first(where: { $0.itemType == .putYourNameInYourCrushsPoll })
        else { return .none }
        let input = God.PurchaseInput(
          coinAmount: crushPoll.coinAmount,
          storeItemId: crushPoll.id,
          targetUserId: .init(stringLiteral: userId)
        )
        return .run { send in
          await purchaseRequest(send: send, input: input)
        }

      case .pickFriend:
        return .none
      }
    }
    .ifLet(\.$pickFriend, action: \.pickFriend) {
      PickFriendToAddYourNameTheirPollLogic()
    }
  }

  private func storeRequest(send: Send<Action>) async {
    do {
      for try await data in godClient.store() {
        await send(.storeResponse(.success(data)), animation: .default)
      }
    } catch {
      await send(.storeResponse(.failure(error)), animation: .default)
    }
  }

  private func purchaseRequest(send: Send<Action>, input: God.PurchaseInput) async {
    analytics.logEvent("store_item_purchase", [
      "store_item_id": input.storeItemId,
      "coin_amount": input.coinAmount,
    ])
    await send(.purchaseResponse(TaskResult {
      try await godClient.purchase(input)
    }))
  }
}

public struct ShopView: View {
  let store: StoreOf<ShopLogic>

  public init(store: StoreOf<ShopLogic>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      VStack(spacing: 0) {
        Text("YOUR BALANCE", bundle: .module)
          .foregroundStyle(Color.gray)

        Spacer()
          .frame(height: 18)

        HStack {
          Image(.coin)
            .resizable()
            .frame(width: 38, height: 38)

          Text(verbatim: viewStore.coinBalance.description)
            .font(.system(size: 40, weight: .black, design: .rounded))
            .contentTransition(.numericText(countsDown: true))
        }
        .foregroundStyle(Color.yellow)

        Spacer()
          .frame(height: 34)

        VStack(spacing: 8) {
          Text("Boost Your Name in Polls", bundle: .module)
            .foregroundStyle(Color.white)

          Text("Use coins to get featured in polls", bundle: .module)
            .foregroundStyle(Color.gray)
        }
        .multilineTextAlignment(.center)

        Spacer()
          .frame(height: 18)

        VStack {
          ForEach(viewStore.items, id: \.self) { item in
            ShopItemView(
              id: item.id,
              name: item.title.ja,
              description: item.description?.ja,
              amount: item.coinAmount,
              imageURL: item.imageURL
            ) {
              store.send(.purchaseButtonTapped(id: item.id))
            }
          }
        }
        .padding(.horizontal, 16)

        Spacer()

        VStack(spacing: 8) {
          Text("How do I get more coins?", bundle: .module)
            .foregroundStyle(Color.white)
          Text("Answer polls about your friends to win coins.", bundle: .module)
            .foregroundStyle(Color.gray)
        }
      }
      .frame(maxWidth: .infinity)
      .background(Color.black)
      .navigationTitle(Text("Shop", bundle: .module))
      .navigationBarTitleDisplayMode(.inline)
      .task { await store.send(.onTask).finish() }
      .onAppear { store.send(.onAppear) }
      .alert(store: store.scope(state: \.$alert, action: \.alert))
      .fullScreenCover(
        store: store.scope(state: \.$pickFriend, action: \.pickFriend)
      ) { store in
        NavigationStack {
          PickFriendToAddYourNameTheirPollView(store: store)
        }
      }
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button {
            store.send(.closeButtonTapped)
          } label: {
            Image(systemName: "xmark")
              .foregroundStyle(Color.white)
          }
        }
      }
    }
  }
}

#Preview {
  NavigationStack {
    ShopView(
      store: .init(
        initialState: ShopLogic.State(),
        reducer: { ShopLogic() }
      )
    )
  }
}

extension AlertState where Action == ShopLogic.Action.Alert {
  static let insufficientFundsForCoin = Self {
    TextState("Error")
  } actions: {
    ButtonState(action: .confirmOkay) {
      TextState("OK")
    }
  } message: {
    TextState("You don't have enough coins", bundle: .module)
  }

  static let purchaseSuccess = Self {
    TextState("Success", bundle: .module)
  } actions: {
    ButtonState(action: .confirmOkay) {
      TextState("OK")
    }
  } message: {
    TextState("The item was successfully purchased.", bundle: .module)
  }
}
