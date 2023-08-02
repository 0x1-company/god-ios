import ComposableArchitecture
import SwiftUI

public struct ShopReducer: Reducer {
  public init() {}

  public struct State: Equatable {
    public init() {}
  }

  public enum Action: Equatable {
    case onTask
    case closeButtonTapped
  }

  @Dependency(\.dismiss) var dismiss

  public var body: some Reducer<State, Action> {
    Reduce { _, action in
      switch action {
      case .onTask:
        return .none
      case .closeButtonTapped:
        return .run { _ in
          await self.dismiss()
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
          ShopItemView(
            name: "Get Your Name on 3 Random Polls",
            description: nil,
            amount: 100
          )

          ShopItemView(
            name: "Put Your Name in Your Crush's Poll",
            description: "Your name remains secret",
            amount: 300
          )
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
              reducer: ShopReducer()
            )
          )
        }
      }
  }
}
