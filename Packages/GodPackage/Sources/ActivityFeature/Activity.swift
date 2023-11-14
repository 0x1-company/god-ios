import AnalyticsClient
import AsyncValue
import ComposableArchitecture
import God
import GodClient
import ProfileFeature
import ProfileImage
import SwiftUI

@Reducer
public struct ActivityLogic {
  public init() {}

  public struct State: Equatable {
    var pagination = AsyncValue<God.NextPaginationFragment>.none
    var edges: [God.ActivitiesQuery.Data.ListActivities.Edge] = []
    @PresentationState var destination: Destination.State?
    public init() {}
  }

  public enum Action {
    case onTask
    case onAppear
    case activitiesResponse(TaskResult<God.ActivitiesQuery.Data>)
    case activityButtonTapped(God.ActivitiesQuery.Data.ListActivities.Edge)
    case destination(PresentationAction<Destination.Action>)
  }

  @Dependency(\.analytics) var analytics
  @Dependency(\.godClient.activities) var activitiesStream

  enum Cancel { case activities }

  public var body: some Reducer<State, Action> {
    Reduce<State, Action> { state, action in
      switch action {
      case .onTask:
        state.pagination = .loading
        return .run { send in
          for try await data in activitiesStream(nil) {
            await send(.activitiesResponse(.success(data)))
          }
        } catch: { error, send in
          await send(.activitiesResponse(.failure(error)))
        }
        .cancellable(id: Cancel.activities)

      case .onAppear:
        analytics.logScreen(screenName: "Activity", of: self)
        return .none

      case let .activitiesResponse(.success(data)):
        state.edges = data.listActivities.edges
        state.pagination = .success(data.listActivities.pageInfo.fragments.nextPaginationFragment)
        return .none

      case .activitiesResponse(.failure):
        state.edges = []
        state.pagination = .none
        return .none

      case let .activityButtonTapped(edge):
        state.destination = .profile(
          ProfileExternalLogic.State(
            userId: edge.node.userId
          )
        )
        return .none

      case .destination(.dismiss):
        state.destination = nil
        return .none

      case .destination:
        return .none
      }
    }
    .ifLet(\.$destination, action: \.destination) {
      Destination()
    }
  }

  @Reducer
  public struct Destination {
    public enum State: Equatable {
      case profile(ProfileExternalLogic.State)
    }

    public enum Action {
      case profile(ProfileExternalLogic.Action)
    }

    public var body: some Reducer<State, Action> {
      Scope(state: /State.profile, action: /Action.profile) {
        ProfileExternalLogic()
      }
    }
  }
}

public struct ActivityView: View {
  let store: StoreOf<ActivityLogic>

  public init(store: StoreOf<ActivityLogic>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      List {
        ForEach(viewStore.edges, id: \.cursor) { edge in
          ActivityCard(activity: edge) { activity in
            store.send(.activityButtonTapped(activity))
          }
        }
      }
      .listStyle(.plain)
      .task { await store.send(.onTask).finish() }
      .onAppear { store.send(.onAppear) }
      .sheet(
        store: store.scope(state: \.$destination, action: { .destination($0) }),
        state: /ActivityLogic.Destination.State.profile,
        action: ActivityLogic.Destination.Action.profile
      ) { store in
        NavigationStack {
          ProfileExternalView(store: store)
        }
      }
    }
  }
}

#Preview {
  ActivityView(
    store: .init(
      initialState: ActivityLogic.State(),
      reducer: { ActivityLogic() }
    )
  )
}
