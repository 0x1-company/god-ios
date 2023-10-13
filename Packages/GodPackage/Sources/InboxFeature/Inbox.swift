import AnimationDisableTransaction
import Build
import Styleguide
import ComposableArchitecture
import God
import GodClient
import GodModeFeature
import StoreKit
import StoreKitClient
import SwiftUI
import UserNotificationClient

public struct InboxLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    var fromGodTeamCard = FromGodTeamCardLogic.State()
    @PresentationState var destination: Destination.State?
    var notificationsReEnable: NotificationsReEnableLogic.State?

    var inboxActivities: [God.InboxCardFragment] = []
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
    case inboxActivityResponse(TaskResult<God.InboxActivityQuery.Data>)
    case readActivityResponse(TaskResult<God.ReadActivityMutation.Data>)
    case notificationSettings(TaskResult<UserNotificationClient.Notification.Settings>)
    case destination(PresentationAction<Destination.Action>)
    case fromGodTeamCard(FromGodTeamCardLogic.Action)
    case notificationsReEnable(NotificationsReEnableLogic.Action)
  }

  @Dependency(\.build) var build
  @Dependency(\.store) var storeClient
  @Dependency(\.godClient) var godClient
  @Dependency(\.userNotifications) var userNotifications

  enum Cancel {
    case readActivity
    case inboxActivity
    case inboxActivities
  }

  public var body: some Reducer<State, Action> {
    Scope(state: \.fromGodTeamCard, action: /Action.fromGodTeamCard) {
      FromGodTeamCardLogic()
    }
    Reduce<State, Action> { _, action in
      if case .notificationSettings = action {
        return .none
      }
      return .run { send in
        await send(.notificationSettings(TaskResult {
          await userNotifications.getNotificationSettings()
        }))
      }
    }
    Reduce<State, Action> { state, action in
      switch action {
      case .onTask:
        guard let id = build.infoDictionary("GOD_MODE_ID", for: String.self)
        else { return .none }
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
      case let .activityButtonTapped(activityId):
        return Effect<Action>.merge(
          Effect<Action>.run(operation: { send in
            await inboxActivityRequest(send: send, id: activityId)
          })
          .cancellable(id: Cancel.inboxActivity, cancelInFlight: true),

          Effect<Action>.run(operation: { send in
            await readActivityRequest(send: send, activityId: activityId)
          })
          .cancellable(id: Cancel.readActivity, cancelInFlight: true)
        )

      case .seeWhoLikesYouButtonTapped:
        guard let id = build.infoDictionary("GOD_MODE_ID", for: String.self)
        else { return .none }
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
        let inboxes = data.listInboxActivities.edges.map(\.node.fragments.inboxCardFragment)
        state.inboxActivities = inboxes
        return .none

      case let .activeSubscriptionResponse(.success(data)):
        state.subscription = data.activeSubscription
        return .none

      case let .inboxActivityResponse(.success(data)):
        let activity = data.inboxActivity.fragments.inboxFragment
        let isInGodMode = state.subscription != nil
        state.destination = .inboxDetail(
          .init(activity: activity, isInGodMode: isInGodMode)
        )
        return .none

      case .readActivityResponse(.success):
        return .run { send in
          await inboxActivitiesRequest(send: send)
        }
        .cancellable(id: Cancel.inboxActivities, cancelInFlight: true)

      case let .notificationSettings(.success(settings)):
        let isAuthorized = settings.authorizationStatus == .authorized
        state.notificationsReEnable = isAuthorized ? nil : .init()
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
    .ifLet(\.notificationsReEnable, action: /Action.notificationsReEnable) {
      NotificationsReEnableLogic()
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

  func inboxActivityRequest(send: Send<Action>, id: String) async {
    do {
      for try await data in godClient.inboxActivity(id) {
        await send(.inboxActivityResponse(.success(data)), transaction: .animationDisable)
      }
    } catch {
      await send(.inboxActivityResponse(.failure(error)))
    }
  }

  func readActivityRequest(send: Send<Action>, activityId: String) async {
    await send(.readActivityResponse(TaskResult {
      try await godClient.readActivity(activityId)
    }))
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
        VStack(spacing: 0) {
          IfLetStore(
            store.scope(state: \.notificationsReEnable, action: InboxLogic.Action.notificationsReEnable),
            then: NotificationsReEnableView.init(store:)
          )
          List {
            ForEach(viewStore.inboxActivities, id: \.self) { inbox in
              InboxCard(inbox: inbox) {
                viewStore.send(.activityButtonTapped(id: inbox.id))
              }
            }

            FromGodTeamCard(store: store.scope(state: \.fromGodTeamCard, action: InboxLogic.Action.fromGodTeamCard))

            Spacer()
              .listRowSeparator(.hidden)
              .frame(height: 80)
          }
          .listStyle(.plain)
        }

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
