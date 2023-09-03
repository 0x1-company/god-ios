import ComposableArchitecture
import SwiftUI

public struct ActivityLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    public init() {}
  }

  public enum Action: Equatable {
    case onTask
  }

  public var body: some Reducer<State, Action> {
    Reduce { _, action in
      switch action {
      case .onTask:
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
        ForEach(0 ..< 100, id: \.self) { _ in
          HStack(alignment: .top, spacing: 16) {
            Color.red
              .frame(width: 44, height: 44)
              .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
              HStack(spacing: 0) {
                Text("Satoya Hatanaka")
                  .bold()
                Text(" received")
              }
              Text("Harvard would be lucky to have them as a student")
              Text("From a boy in 9th grade")
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
