import RoundedCorner
import AnalyticsClient
import ComposableArchitecture
import Styleguide
import SwiftUI
import God
import GodClient

public struct ClubActivitySettingLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    var clubActivities: [God.ClubActivityCardFragment] = []
    public init() {}
  }

  public enum Action: Equatable {
    case onTask
    case onAppear
    case clubActivityButtonTapped(String)
    case clubActivitiesResponse(TaskResult<God.ClubActivitiesQuery.Data>)
  }

  @Dependency(\.analytics) var analytics
  @Dependency(\.godClient) var godClient
  
  enum Cancel {
    case clubActivities
  }

  public var body: some Reducer<State, Action> {
    Reduce<State, Action> { state, action in
      switch action {
      case .onTask:
        return .run { send in
          await clubActivitiesRequest(send: send)
        }

      case .onAppear:
        analytics.logScreen(screenName: "ClubActivitySetting", of: self)
        return .none
        
      case let .clubActivityButtonTapped(id):
        print(id)
        return .none

      case let .clubActivitiesResponse(.success(data)):
        state.clubActivities = data.clubActivities.map(\.fragments.clubActivityCardFragment)
        return .none
        
      case .clubActivitiesResponse(.failure):
        return .none
      }
    }
  }
  
  func clubActivitiesRequest(send: Send<Action>) async {
    await withTaskCancellation(id: Cancel.clubActivities, cancelInFlight: true) {
      do {
        for try await data in godClient.clubActivities() {
          await send(.clubActivitiesResponse(.success(data)))
        }
      } catch {
        await send(.clubActivitiesResponse(.failure(error)))
      }
    }
  }
}

public struct ClubActivitySettingView: View {
  let store: StoreOf<ClubActivitySettingLogic>

  public init(store: StoreOf<ClubActivitySettingLogic>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      ZStack {
        Color.godService
        
        List(viewStore.clubActivities, id: \.self) { clubActivity in
          ClubActivityCard(clubActivity: clubActivity) {
            store.send(.clubActivityButtonTapped(clubActivity.id))
          }
        }
        .listStyle(.plain)
        .foregroundStyle(.primary)
        .background(Color.white)
        .multilineTextAlignment(.center)
        .cornerRadius(12, corners: [.topLeft, .topRight])
        .edgesIgnoringSafeArea(.bottom)
      }
      .task { await store.send(.onTask).finish() }
      .onAppear { store.send(.onAppear) }
      .navigationTitle(Text("Pick your club activity", bundle: .module))
      .navigationBarTitleDisplayMode(.inline)
      .toolbarBackground(Color.godService, for: .navigationBar)
      .toolbarBackground(.visible, for: .navigationBar)
      .toolbarColorScheme(.dark, for: .navigationBar)
    }
  }
  
  struct ClubActivityCard: View {
    let clubActivity: God.ClubActivityCardFragment
    let action: () -> Void

    var body: some View {
      Button(action: action) {
        HStack(alignment: .center, spacing: 16) {
          Text(clubActivity.name)
            .font(.system(.body, design: .rounded, weight: .bold))
        }
      }
    }
  }
}

#Preview {
  ClubActivitySettingView(
    store: .init(
      initialState: ClubActivitySettingLogic.State(),
      reducer: { ClubActivitySettingLogic() }
    )
  )
}
