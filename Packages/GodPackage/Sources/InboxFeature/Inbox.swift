import AnalyticsClient
import AnimationDisableTransaction
import Build
import ComposableArchitecture
import God
import GodClient
import GodModeFeature
import StoreKit
import StoreKitClient
import Styleguide
import SwiftUI
import UserNotificationClient

public struct InboxLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    var fromGodTeamCard = FromGodTeamCardLogic.State()
    @PresentationState var destination: Destination.State?
    var notificationsReEnable: NotificationsReEnableLogic.State?

    var banners: [God.BannerCardFragment] = []
    var inboxActivities: [God.InboxCardFragment] = []
    var products: [Product] = []
    var subscription: God.ActiveSubscriptionQuery.Data.ActiveSubscription?

    public init() {}
  }

  public enum Action: Equatable {
    case onTask
    case onAppear
    case activityButtonTapped(id: String)
    case seeWhoLikesYouButtonTapped
    case productsResponse(TaskResult<[Product]>)
    case inboxActivitiesResponse(TaskResult<God.InboxActivitiesQuery.Data>)
    case activeSubscriptionResponse(TaskResult<God.ActiveSubscriptionQuery.Data>)
    case inboxActivityResponse(TaskResult<God.InboxActivityQuery.Data>)
    case readActivityResponse(TaskResult<God.ReadActivityMutation.Data>)
    case bannersResponse(TaskResult<God.BannersQuery.Data>)
    case notificationSettings(TaskResult<UserNotificationClient.Notification.Settings>)
    case destination(PresentationAction<Destination.Action>)
    case fromGodTeamCard(FromGodTeamCardLogic.Action)
    case notificationsReEnable(NotificationsReEnableLogic.Action)
  }

  @Dependency(\.build) var build
  @Dependency(\.date.now) var now
  @Dependency(\.store) var storeClient
  @Dependency(\.godClient) var godClient
  @Dependency(\.analytics) var analytics
  @Dependency(\.userNotifications) var userNotifications

  enum Cancel {
    case products
    case readActivity
    case inboxActivity
    case inboxActivities
    case banners
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
              await bannersRequest(send: send)
            }
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
      case .onAppear:
        analytics.logScreen(screenName: "Inbox", of: self)
        return .none
      case let .activityButtonTapped(activityId):
        return .run { send in
          await withTaskGroup(of: Void.self) { group in
            group.addTask {
              await inboxActivityRequest(send: send, id: activityId)
            }
            group.addTask {
              await readActivityRequest(send: send, activityId: activityId)
            }
          }
        }

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

      case let .bannersResponse(.success(data)):
        state.banners = data.banners
          .map(\.fragments.bannerCardFragment)
          .filter { banner in
            guard
              let startAtTimeInterval = TimeInterval(banner.startAt),
              let endAtTimeInterval = TimeInterval(banner.endAt)
            else { return false }
            let startAt = Date(timeIntervalSince1970: startAtTimeInterval / 1000.0)
            let endAt = Date(timeIntervalSince1970: endAtTimeInterval / 1000.0)
            return startAt < now && now < endAt
          }
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
    await withTaskCancellation(id: Cancel.products, cancelInFlight: true) {
      await send(.productsResponse(TaskResult {
        try await storeClient.products(ids)
      }))
    }
  }

  func inboxActivitiesRequest(send: Send<Action>) async {
    await withTaskCancellation(id: Cancel.inboxActivities, cancelInFlight: true) {
      do {
        for try await data in godClient.inboxActivities() {
          await send(.inboxActivitiesResponse(.success(data)))
        }
      } catch {
        await send(.inboxActivitiesResponse(.failure(error)))
      }
    }
  }

  func inboxActivityRequest(send: Send<Action>, id: String) async {
    await withTaskCancellation(id: Cancel.inboxActivity, cancelInFlight: true) {
      do {
        for try await data in godClient.inboxActivity(id) {
          await send(.inboxActivityResponse(.success(data)), transaction: .animationDisable)
        }
      } catch {
        await send(.inboxActivityResponse(.failure(error)))
      }
    }
  }

  func readActivityRequest(send: Send<Action>, activityId: String) async {
    await withTaskCancellation(id: Cancel.readActivity, cancelInFlight: true) {
      await send(.readActivityResponse(TaskResult {
        try await godClient.readActivity(activityId)
      }))
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

  func bannersRequest(send: Send<Action>) async {
    await withTaskCancellation(id: Cancel.banners, cancelInFlight: true) {
      do {
        for try await data in godClient.banners() {
          await send(.bannersResponse(.success(data)))
        }
      } catch {
        await send(.bannersResponse(.failure(error)))
      }
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
          ForEach(viewStore.banners, id: \.id) { banner in
            BannerCard(banner: banner)
          }
          IfLetStore(
            store.scope(state: \.notificationsReEnable, action: InboxLogic.Action.notificationsReEnable),
            then: NotificationsReEnableView.init(store:)
          )
          List {
            ForEach(viewStore.inboxActivities, id: \.self) { inbox in
              InboxCard(inbox: inbox) {
                store.send(.activityButtonTapped(id: inbox.id))
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
              store.send(.seeWhoLikesYouButtonTapped)
            } label: {
              Label {
                Text("See who likes you", bundle: .module)
              } icon: {
                Image(systemName: "lock.fill")
              }
            }
            .buttonStyle(SeeWhoLikesYouButtonStyle())
          }
          .ignoresSafeArea()
          .frame(height: 64)
        }
      }
      .task { await store.send(.onTask).finish() }
      .onAppear { store.send(.onAppear) }
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
