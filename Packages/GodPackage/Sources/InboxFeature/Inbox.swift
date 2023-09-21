import AnimationDisableTransaction
import ButtonStyles
import ComposableArchitecture
import God
import GodClient
import GodModeFeature
import StoreKit
import StoreKitClient
import SwiftUI

public struct InboxLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    @PresentationState var destination: Destination.State?

    var inboxes: [InboxCardState] = []
    var products: [Product] = []

    public init() {}

    public struct InboxCardState: Equatable, Identifiable {
      public let id: String
      let gender: String
      let createdAt: Date
      let isRead: Bool
    }
  }

  public enum Action: Equatable {
    case onTask
    case activityButtonTapped
    case fromGodTeamButtonTapped
    case seeWhoLikesYouButtonTapped
    case productsResponse(TaskResult<[Product]>)
    case inboxActivitiesResponse(TaskResult<God.InboxActivitiesQuery.Data>)
    case destination(PresentationAction<Destination.Action>)
  }

  @Dependency(\.store) var storeClient
  @Dependency(\.godClient) var godClient

  public var body: some Reducer<State, Action> {
    Reduce<State, Action> { state, action in
      switch action {
      case .onTask:
        let id = storeClient.godModeId()
        return .run { send in
          await withTaskGroup(of: Void.self) { group in
            group.addTask {
              await send(.productsResponse(TaskResult {
                try await storeClient.products([id])
              }))
            }
            group.addTask {
              do {
                for try await data in godClient.inboxActivities() {
                  await send(.inboxActivitiesResponse(.success(data)))
                }
              } catch {
                await send(.inboxActivitiesResponse(.failure(error)))
              }
            }
          }
        }
      case .activityButtonTapped:
        state.destination = .inboxDetail()
        return .none

      case .fromGodTeamButtonTapped:
        state.destination = .fromGodTeam(.init())
        return .none

      case .seeWhoLikesYouButtonTapped:
        let id = storeClient.godModeId()
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

      case let .inboxActivitiesResponse(.success(data)):
        let inboxes = data.listInboxActivities.edges.map(\.node.fragments.inboxFragment)
        state.inboxes = inboxes.compactMap {
          guard let createdAt = TimeInterval($0.createdAt)
          else { return nil }
          return State.InboxCardState(
            id: $0.id,
            gender: "",
            createdAt: Date(timeIntervalSince1970: createdAt / 1000.0),
            isRead: $0.isRead
          )
        }
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
      case inboxDetail(InboxDetailLogic.State = .init())
      case activatedGodMode(ActivatedGodModeLogic.State = .init())
    }

    public enum Action: Equatable {
      case godMode(GodModeLogic.Action)
      case fromGodTeam(FromGodTeamLogic.Action)
      case inboxDetail(InboxDetailLogic.Action)
      case activatedGodMode(ActivatedGodModeLogic.Action)
    }

    public var body: some Reducer<State, Action> {
      Scope(state: /State.godMode, action: /Action.godMode, child: GodModeLogic.init)
      Scope(state: /State.fromGodTeam, action: /Action.fromGodTeam, child: FromGodTeamLogic.init)
      Scope(state: /State.inboxDetail, action: /Action.inboxDetail, child: InboxDetailLogic.init)
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
          ForEach(viewStore.inboxes) { state in
            InboxCard(
              gender: state.gender,
              createdAt: state.createdAt,
              isRead: state.isRead
            ) {
              viewStore.send(.activityButtonTapped, transaction: .animationDisable)
            }
          }

          FromGodTeamCard {
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
              Label {
                Text("See who likes you", bundle: .module)
              } icon: {
                Image(systemName: "lock.fill")
              }
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
      .sheet(
        store: store.scope(state: \.$destination, action: { .destination($0) }),
        state: /InboxLogic.Destination.State.activatedGodMode,
        action: InboxLogic.Destination.Action.activatedGodMode
      ) { store in
        ActivatedGodModeView(store: store)
          .presentationDetents([.fraction(0.4)])
      }
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
        state: /InboxLogic.Destination.State.inboxDetail,
        action: InboxLogic.Destination.Action.inboxDetail,
        content: InboxDetailView.init(store:)
      )
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
