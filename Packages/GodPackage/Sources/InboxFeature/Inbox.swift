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
    var fromGodTeamCard = FromGodTeamCardLogic.State()
    @PresentationState var destination: Destination.State?

    var inboxActivities: [God.InboxFragment] = []
    var products: [Product] = []
    var subscription: God.ActiveSubscriptionQuery.Data.ActiveSubscription?

    public init() {}
  }

  public enum Action: Equatable {
    case onTask
    case activityButtonTapped(id: String)
    case seeWhoLikesYouButtonTapped
    case productsResponse(TaskResult<[Product]>)
    case inboxActivitiesResponse(TaskResult<God.InboxActivitiesQuery.Data>)
    case activeSubscriptionResponse(TaskResult<God.ActiveSubscriptionQuery.Data>)
    case destination(PresentationAction<Destination.Action>)
    case fromGodTeamCard(FromGodTeamCardLogic.Action)
  }

  @Dependency(\.store) var storeClient
  @Dependency(\.godClient) var godClient

  enum Cancel {
    case readActivity
  }

  public var body: some Reducer<State, Action> {
    Scope(state: \.fromGodTeamCard, action: /Action.fromGodTeamCard) {
      FromGodTeamCardLogic()
    }
    Reduce<State, Action> { state, action in
      switch action {
      case .onTask:
        let id = storeClient.godModeId()
        return .run { send in
          await withTaskGroup(of: Void.self) { group in
            group.addTask {
              await productsRequest(send: send, ids: [id])
            }
            group.addTask {
              await inboxActivitiesRequest(send: send)
            }
            group.addTask {
              await activeSubscriptionRequest(send: send)
            }
          }
        }
      case let .activityButtonTapped(id):
        let isInGodMode = state.subscription != nil
        guard let activity = state.inboxActivities.first(where: { $0.id == id })
        else { return .none }
        state.destination = .inboxDetail(
          .init(activity: activity, isInGodMode: isInGodMode)
        )
        return .run { send in
          _ = try await godClient.readActivity(id)
          await inboxActivitiesRequest(send: send)
        }
        .cancellable(id: Cancel.readActivity, cancelInFlight: true)

      case .seeWhoLikesYouButtonTapped:
        let id = storeClient.godModeId()
        guard let product = state.products.first(where: { $0.id == id })
        else { return .none }
        state.destination = .godMode(.init(product: product))
        return .none

      case let .productsResponse(.success(products)):
        state.products = products
        return .none

      case .productsResponse(.failure):
        return .none

      case .destination(.presented(.godMode(.delegate(.activated)))):
        state.destination = .activatedGodMode()
        return .run { send in
          await withThrowingTaskGroup(of: Void.self) { group in
            group.addTask {
              await activeSubscriptionRequest(send: send)
            }
            group.addTask {
              await inboxActivitiesRequest(send: send)
            }
          }
        }
      case let .inboxActivitiesResponse(.success(data)):
        let inboxes = data.listInboxActivities.edges.map(\.node.fragments.inboxFragment)
        state.inboxActivities = inboxes
        return .none

      case let .activeSubscriptionResponse(.success(data)):
        state.subscription = data.activeSubscription
        return .none

      case .fromGodTeamCard(.delegate(.showDetail)):
        state.destination = .fromGodTeam(.init())
        return .none

      default:
        return .none
      }
    }
    .ifLet(\.$destination, action: /Action.destination) {
      Destination()
    }
  }

  func productsRequest(send: Send<Action>, ids: [String]) async {
    await send(.productsResponse(TaskResult {
      try await storeClient.products(ids)
    }))
  }

  func inboxActivitiesRequest(send: Send<Action>) async {
    do {
      for try await data in godClient.inboxActivities() {
        await send(.inboxActivitiesResponse(.success(data)))
      }
    } catch {
      await send(.inboxActivitiesResponse(.failure(error)))
    }
  }

  func activeSubscriptionRequest(send: Send<Action>) async {
    do {
      for try await data in godClient.activeSubscription() {
        await send(.activeSubscriptionResponse(.success(data)))
      }
    } catch {
      await send(.activeSubscriptionResponse(.failure(error)))
    }
  }

  public struct Destination: Reducer {
    public enum State: Equatable {
      case godMode(GodModeLogic.State)
      case fromGodTeam(FromGodTeamLogic.State)
      case inboxDetail(InboxDetailLogic.State)
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
          ForEach(viewStore.inboxActivities, id: \.self) { inbox in
            InboxCard(inbox: inbox) {
              viewStore.send(.activityButtonTapped(id: inbox.id), transaction: .animationDisable)
            }
          }

          FromGodTeamCard(store: store.scope(state: \.fromGodTeamCard, action: InboxLogic.Action.fromGodTeamCard))

          Spacer()
            .listRowSeparator(.hidden)
            .frame(height: 80)
        }
        .listStyle(.plain)

        if !viewStore.products.isEmpty, viewStore.subscription == nil {
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
              .frame(height: 56)
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
