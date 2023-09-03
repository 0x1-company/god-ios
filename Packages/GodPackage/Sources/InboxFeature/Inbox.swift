import ButtonStyles
import ColorHex
import ComposableArchitecture
import GodModeFeature
import LabeledButton
import SwiftUI
import StoreKit
import StoreKitClient

public struct InboxReducer: Reducer {
  public init() {}

  public struct State: Equatable {
    @PresentationState var godMode: GodModeReducer.State?
    @PresentationState var fromGodTeam: FromGodTeamReducer.State?
    @PresentationState var activatedGodMode: ActivatedGodModeReducer.State?
    
    var products: [Product] = []

    public init() {}
  }

  public enum Action: Equatable {
    case onTask
    case fromGodTeamButtonTapped
    case seeWhoLikesYouButtonTapped
    case productsResponse(TaskResult<[Product]>)
    case godMode(PresentationAction<GodModeReducer.Action>)
    case fromGodTeam(PresentationAction<FromGodTeamReducer.Action>)
    case activatedGodMode(PresentationAction<ActivatedGodModeReducer.Action>)
  }
  
  @Dependency(\.store) var storeClient

  public var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .onTask:
        let id = storeClient.godModeDefault()
        return .run { send in
          await send(
            .productsResponse(
              TaskResult {
                try await storeClient.products([id])
              }
            )
          )
        }
      case .fromGodTeamButtonTapped:
        state.fromGodTeam = .init()
        return .none

      case .seeWhoLikesYouButtonTapped:
        let id = storeClient.godModeDefault()
        guard let product = state.products.first(where: { $0.id == id })
        else { return .none }
        state.godMode = .init(product: product)
        return .none

      case let .productsResponse(.success(products)):
        state.products = products
        return .none

      case let .productsResponse(.failure(error)):
        print(error)
        return .none
        
      case .godMode(.presented(.delegate(.activated))):
        // display to ACTIVATED GOD MODE
        state.activatedGodMode = .init()
        return .none

      default:
        return .none
      }
    }
    .ifLet(\.$godMode, action: /Action.godMode) {
      GodModeReducer()
    }
    .ifLet(\.$fromGodTeam, action: /Action.fromGodTeam) {
      FromGodTeamReducer()
    }
    .ifLet(\.$activatedGodMode, action: /Action.activatedGodMode) {
      ActivatedGodModeReducer()
    }
  }
}

public struct InboxView: View {
  let store: StoreOf<InboxReducer>

  public init(store: StoreOf<InboxReducer>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      ZStack(alignment: .bottom) {
        List {
          ForEach(0 ..< 4) { _ in
            InboxCard(title: "From a Boy", action: {})
          }

          InboxCard(title: "From God Team") {
            viewStore.send(.fromGodTeamButtonTapped)
          }

          Spacer()
            .listRowSeparator(.hidden)
            .frame(height: 80)
        }
        .listStyle(.plain)
        
        if !viewStore.products.isEmpty {
          ZStack(alignment: .top) {
            Color.white.blur(radius: 1.0)

            Button {
              viewStore.send(.seeWhoLikesYouButtonTapped)
            } label: {
              Label("See who likes you", systemImage: "lock.fill")
                .frame(height: 50)
                .frame(maxWidth: .infinity)
                .bold()
                .foregroundColor(.white)
                .background(Color.black)
                .clipShape(Capsule())
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
            .buttonStyle(HoldDownButtonStyle())
          }
          .ignoresSafeArea()
          .frame(height: 64)
        }
      }
      .task { await viewStore.send(.onTask).finish() }
      .fullScreenCover(
        store: store.scope(
          state: \.$godMode,
          action: InboxReducer.Action.godMode
        ),
        content: GodModeView.init(store:)
      )
      .fullScreenCover(
        store: store.scope(
          state: \.$fromGodTeam,
          action: InboxReducer.Action.fromGodTeam
        ),
        content: FromGodTeamView.init(store:)
      )
      .sheet(
        store: store.scope(
          state: \.$activatedGodMode,
          action: InboxReducer.Action.activatedGodMode
        )
      ) { store in
        ActivatedGodModeView(store: store)
          .presentationDetents([.medium])
      }
    }
  }
}

struct InboxViewPreviews: PreviewProvider {
  static var previews: some View {
    InboxView(
      store: .init(
        initialState: InboxReducer.State(),
        reducer: { InboxReducer() }
      )
    )
  }
}
