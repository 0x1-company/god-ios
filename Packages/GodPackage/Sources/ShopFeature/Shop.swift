import ComposableArchitecture
import SwiftUI
import God
import GodClient

public struct ShopReducer: Reducer {
  public init() {}

  public struct State: Equatable {
    var storeItems: [God.StoreQuery.Data.Store.Item] = []
    public init() {}
  }

  public enum Action: Equatable {
    case onTask
    case responseStore(TaskResult<God.StoreQuery.Data>)
    case closeButtonTapped
  }

  @Dependency(\.dismiss) var dismiss
  @Dependency(\.godClient) var godClient

  public var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .onTask:
        enum CancelID { case effect }
        return .run { send in
          for try await data in self.godClient.store() {
            await send(.responseStore(.success(data)), animation: .default)
          }
        } catch: { error, send in
          await send(.responseStore(.failure(error)), animation: .default)
        }
        .cancellable(id: CancelID.effect)
        
      case let .responseStore(.success(data)):
        state.storeItems = data.store.items
        return .none

      case let .responseStore(.failure(error)):
        print(error)
        return .none
        
      case .closeButtonTapped:
        return .run { _ in
          await dismiss()
        }
      }
    }
  }
}

public struct ShopView: View {
  let store: StoreOf<ShopReducer>

  public init(store: StoreOf<ShopReducer>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      VStack {
        Text("YOUR BALANCE")
          .foregroundColor(Color.gray)
        HStack {
          Text("68")
        }
        .foregroundColor(Color.yellow)

        Text("Boost Your Name in Polls")
          .foregroundColor(Color.white)
        Text("Use coins to get featured in polls")
          .foregroundColor(Color.gray)

        VStack {
          ForEach(viewStore.storeItems, id: \.self) { storeItem in
            ShopItemView(
              name: storeItem.item.title.ja,
              description: nil,
              amount: storeItem.coinAmount
            )
          }
        }
        .padding(.horizontal, 16)

        Spacer()

        Text("How do I get more coins?")
          .foregroundColor(Color.white)
        Text("Answer polls about your friends to win coins.")
          .foregroundColor(Color.gray)
      }
      .background(Color.black.gradient)
      .navigationTitle("Shop")
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

struct ShopViewPreviews: PreviewProvider {
  static var previews: some View {
    Text("")
      .sheet(isPresented: .constant(true)) {
        NavigationStack {
          ShopView(
            store: .init(
              initialState: ShopReducer.State(),
              reducer: { ShopReducer() }
            )
          )
        }
      }
  }
}
