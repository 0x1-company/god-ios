import ButtonStyles
import ColorHex
import ComposableArchitecture
import GodModeFeature
import LabeledButton
import StoreKit
import StoreKitClient
import SwiftUI

public struct InboxLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    @PresentationState var destination: Destination.State?

    var products: [Product] = []

    public init() {}
  }

  public enum Action: Equatable {
    case onTask
    case activityButtonTapped
    case fromGodTeamButtonTapped
    case seeWhoLikesYouButtonTapped
    case productsResponse(TaskResult<[Product]>)
    case destination(PresentationAction<Destination.Action>)
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
      case .activityButtonTapped:
        state.destination = .activityDetail()
        return .none

      case .fromGodTeamButtonTapped:
        state.destination = .fromGodTeam(.init())
        return .none

      case .seeWhoLikesYouButtonTapped:
        let id = storeClient.godModeDefault()
        guard let product = state.products.first(where: { $0.id == id })
        else { return .none }
        state.destination = .godMode(.init(product: product))
        return .none

      case let .productsResponse(.success(products)):
        state.products = products
        return .none

      case let .productsResponse(.failure(error)):
        print(error)
        return .none

      case .destination(.presented(.godMode(.delegate(.activated)))):
        state.destination = .activatedGodMode()
        return .none

      default:
        return .none
      }
    }
    .ifLet(\.$destination, action: /Action.destination) {
      Destination()
    }
  }

  public struct Destination: Reducer {
    public enum State: Equatable {
      case godMode(GodModeLogic.State)
      case fromGodTeam(FromGodTeamLogic.State)
      case activityDetail(ActivityDetailLogic.State = .init())
      case activatedGodMode(ActivatedGodModeLogic.State = .init())
    }

    public enum Action: Equatable {
      case godMode(GodModeLogic.Action)
      case fromGodTeam(FromGodTeamLogic.Action)
      case activityDetail(ActivityDetailLogic.Action)
      case activatedGodMode(ActivatedGodModeLogic.Action)
    }

    public var body: some Reducer<State, Action> {
      Scope(state: /State.godMode, action: /Action.godMode, child: GodModeLogic.init)
      Scope(state: /State.fromGodTeam, action: /Action.fromGodTeam, child: FromGodTeamLogic.init)
      Scope(state: /State.activityDetail, action: /Action.activityDetail, child: ActivityDetailLogic.init)
      Scope(state: /State.activatedGodMode, action: /Action.activatedGodMode, child: ActivatedGodModeLogic.init)
    }
  }
}

public struct InboxView: View {
  let store: StoreOf<InboxLogic>

  public init(store: StoreOf<InboxLogic>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      ZStack(alignment: .bottom) {
        List {
          ForEach(0 ..< 4) { _ in
            InboxCard(title: "From a someone") {
              viewStore.send(.activityButtonTapped, transaction: .animationDisable)
            }
          }

          InboxCard(title: "From God Team") {
            viewStore.send(.fromGodTeamButtonTapped, transaction: .animationDisable)
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
        store: store.scope(state: \.$destination, action: { .destination($0) }),
        state: /InboxLogic.Destination.State.godMode,
        action: InboxLogic.Destination.Action.godMode,
        content: GodModeView.init(store:)
      )
      .fullScreenCover(
        store: store.scope(state: \.$destination, action: { .destination($0) }),
        state: /InboxLogic.Destination.State.fromGodTeam,
        action: InboxLogic.Destination.Action.fromGodTeam,
        content: FromGodTeamView.init(store:)
      )
      .fullScreenCover(
        store: store.scope(state: \.$destination, action: { .destination($0) }),
        state: /InboxLogic.Destination.State.activityDetail,
        action: InboxLogic.Destination.Action.activityDetail,
        content: ActivityDetailView.init(store:)
      )
      .sheet(
        store: store.scope(state: \.$destination, action: { .destination($0) }),
        state: /InboxLogic.Destination.State.activatedGodMode,
        action: InboxLogic.Destination.Action.activatedGodMode
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
        initialState: InboxLogic.State(),
        reducer: { InboxLogic() }
      )
    )
  }
}
