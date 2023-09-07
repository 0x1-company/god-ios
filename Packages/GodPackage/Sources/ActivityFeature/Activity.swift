import AsyncValue
import ComposableArchitecture
import God
import GodClient
import SwiftUI

public struct ActivityLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    var pagination = AsyncValue<God.NextPaginationFragment>.none
    var edges: [God.ActivitiesQuery.Data.ListActivities.Edge] = []
    public init() {}
  }

  public enum Action: Equatable {
    case onTask
    case activitiesResponse(TaskResult<God.ActivitiesQuery.Data>)
  }
  
  @Dependency(\.godClient.activities) var activitiesStream

  public var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .onTask:
        enum Cancel { case id }
        state.pagination = .loading
        return .run { send in
          for try await data in activitiesStream(nil) {
            await send(.activitiesResponse(.success(data)))
          }
        } catch: { error, send in
          await send(.activitiesResponse(.failure(error)))
        }
        .cancellable(id: Cancel.id)

      case let .activitiesResponse(.success(data)):
        state.edges = data.listActivities.edges
        state.pagination = .some(data.listActivities.pageInfo.fragments.nextPaginationFragment)
        return .none

      case .activitiesResponse(.failure):
        state.edges = []
        state.pagination = .none
        return .none
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
          HStack(alignment: .top, spacing: 16) {
            Color.red
              .frame(width: 44, height: 44)
              .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
              HStack(spacing: 0) {
                Text(edge.node.user.displayName.ja)
                  .bold()
              }
              Text(edge.node.question.text.ja)
              Text("3年生の女子より")
                .foregroundColor(.secondary)
            }

            Text("3d")
              .foregroundColor(.secondary)
          }
        }
      }
      .listStyle(.plain)
      .task { await viewStore.send(.onTask).finish() }
    }
  }
}

struct ActivityViewPreviews: PreviewProvider {
  static var previews: some View {
    ActivityView(
      store: .init(
        initialState: ActivityLogic.State(),
        reducer: { ActivityLogic() }
      )
    )
  }
}
