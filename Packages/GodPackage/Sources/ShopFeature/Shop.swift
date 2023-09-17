import ComposableArchitecture
import God
import GodClient
import SwiftUI

public struct ShopLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    var coinBalance = 0
    var items: [God.StoreQuery.Data.Store.Item] = []
    public init() {}
  }

  public enum Action: Equatable {
    case onTask
    case storeResponse(TaskResult<God.StoreQuery.Data>)
    case purchaseButtonTapped(id: String)
    case purchaseResponse(TaskResult<God.PurchaseMutation.Data>)
    case closeButtonTapped
  }

  @Dependency(\.dismiss) var dismiss
  @Dependency(\.godClient) var godClient
  
  public var body: some Reducer<State, Action> {
    Reduce<State, Action> { state, action in
      switch action {
      case .onTask:
        return .run { send in
          await storeRequest(send: send)
        }
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
        switch item.id {
        case "GetYourNameOnThreeRandomPolls":
          let input = God.PurchaseInput(
            coinAmount: item.coinAmount,
            storeItemId: item.id
          )
          return .run { send in
            await send(.purchaseResponse(TaskResult {
              try await godClient.purchase(input)
            }))
          }
        case "PutYourNameInYourCrushsPoll":
          return .none
        default:
          return .none
        }
      case .purchaseResponse(.success):
        return .run { send in
          await storeRequest(send: send)
        }
      case .purchaseResponse(.failure):
        return .none
      case .closeButtonTapped:
        return .run { _ in
          await dismiss()
        }
      }
    }
  }
  
  private func storeRequest(send: Send<Action>) async {
    do {
      for try await data in godClient.store() {
        await send(.storeResponse(.success(data)))
      }
    } catch {
      await send(.storeResponse(.failure(error)))
    }
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
          .foregroundColor(Color.gray)
        
        Spacer()
          .frame(height: 18)
        
        HStack {
          Image(.coin)
            .resizable()
            .frame(width: 38, height: 38)

          Text(verbatim: viewStore.coinBalance.description)
            .font(.largeTitle)
            .bold()
            .contentTransition(.numericText(countsDown: true))
        }
        .foregroundColor(Color.yellow)
        
        Spacer()
          .frame(height: 34)

        VStack(spacing: 8) {
          Text("Boost Your Name in Polls", bundle: .module)
            .foregroundColor(Color.white)
          
          Text("Use coins to get featured in polls", bundle: .module)
            .foregroundColor(Color.gray)
        }
        
        Spacer()
          .frame(height: 18)

        VStack {
          ForEach(viewStore.items, id: \.self) { item in
            ShopItemView(
              name: item.title.ja,
              description: item.description?.ja,
              amount: item.coinAmount
            )
          }
        }
        .padding(.horizontal, 16)

        Spacer()

        VStack(spacing: 8) {
          Text("How do I get more coins?", bundle: .module)
            .foregroundColor(Color.white)
          Text("Answer polls about your friends to win coins.", bundle: .module)
            .foregroundColor(Color.gray)
        }
      }
      .frame(maxWidth: .infinity)
      .background(Color.black)
      .navigationTitle(Text("Shop", bundle: .module))
      .navigationBarTitleDisplayMode(.inline)
      .task { await viewStore.send(.onTask).finish() }
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button {
            viewStore.send(.closeButtonTapped)
          } label: {
            Image(systemName: "xmark")
              .foregroundColor(.primary)
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
