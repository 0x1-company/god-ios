import AboutFeature
import ActivityFeature
import AddFeature
import ComposableArchitecture
import FriendRequestFeature
import God
import GodClient
import GodFeature
import InboxFeature
import ProfileFeature
import SwiftUI

@Reducer
public struct RootNavigationLogic {
  public init() {}

  public enum Tab: LocalizedStringKey, Equatable, CaseIterable {
    case add = "Add+"
    case activity = "Activity"
    case inbox = "Inbox"
    case god = "God"
    case profile = "Profile"
    case about = "About"
  }

  public struct State: Equatable {
    var friendRequestsPending: [God.FriendRequestSheetFragment] = []
    @PresentationState var friendRequestSheet: FriendRequestSheetLogic.State?
    var add = AddLogic.State()
    var activity = ActivityLogic.State()
    var inbox = InboxLogic.State()
    var god = GodLogic.State()
    var profile = ProfileLogic.State()
    var about = AboutLogic.State()
    @BindingState var selectedTab = Tab.god
    public init() {}
  }

  public enum Action: BindableAction {
    case onTask
    case friendRequestResponse(TaskResult<God.FriendRequestsQuery.Data>)
    case performAfterFriendRequestSheetDismiss
    case add(AddLogic.Action)
    case activity(ActivityLogic.Action)
    case inbox(InboxLogic.Action)
    case god(GodLogic.Action)
    case profile(ProfileLogic.Action)
    case about(AboutLogic.Action)
    case binding(BindingAction<State>)
    case friendRequestSheet(PresentationAction<FriendRequestSheetLogic.Action>)
  }

  @Dependency(\.mainQueue) var mainQueue
  @Dependency(\.godClient) var godClient

  enum Cancel {
    case friendRequests
  }

  public var body: some Reducer<State, Action> {
    BindingReducer()
    Scope(state: \.add, action: \.add, child: AddLogic.init)
    Scope(state: \.activity, action: \.activity, child: ActivityLogic.init)
    Scope(state: \.inbox, action: \.inbox, child: InboxLogic.init)
    Scope(state: \.god, action: \.god, child: GodLogic.init)
    Scope(state: \.profile, action: \.profile, child: ProfileLogic.init)
    Scope(state: \.about, action: \.about, child: AboutLogic.init)
    Reduce<State, Action> { state, action in
      switch action {
      case .onTask:
        return .run { send in
          for try await data in godClient.friendRequests() {
            await send(.friendRequestResponse(.success(data)))
          }
        } catch: { error, send in
          await send(.friendRequestResponse(.failure(error)))
        }
        .cancellable(id: Cancel.friendRequests, cancelInFlight: true)

      case let .friendRequestResponse(.success(data)):
        let requests = data.friendRequests.edges.map(\.node.fragments.friendRequestSheetFragment)
        state.friendRequestsPending = requests

        if let latest = requests.first {
          state.friendRequestSheet = .init(friend: latest)
        }

        return .cancel(id: Cancel.friendRequests)

      case .friendRequestResponse(.failure):
        return .cancel(id: Cancel.friendRequests)

      case .friendRequestSheet(.dismiss):
        state.friendRequestSheet = nil
        _ = state.friendRequestsPending.removeFirst()
        return .run { send in
          try await mainQueue.sleep(for: .seconds(0.5))
          await send(.performAfterFriendRequestSheetDismiss)
        }

      case .performAfterFriendRequestSheetDismiss:
        guard let latest = state.friendRequestsPending.first
        else { return .none }
        state.friendRequestSheet = .init(friend: latest)
        return .none

      default:
        return .none
      }
    }
    .ifLet(\.$friendRequestSheet, action: \.friendRequestSheet) {
      FriendRequestSheetLogic()
    }
  }
}

public struct RootNavigationView: View {
  let store: StoreOf<RootNavigationLogic>

  public init(store: StoreOf<RootNavigationLogic>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      TabView(selection: viewStore.$selectedTab) {
        AddView(
          store: store.scope(
            state: \.add,
            action: RootNavigationLogic.Action.add
          )
        )
        .padding(.top, 52)
        .tag(RootNavigationLogic.Tab.add)

        ActivityView(
          store: store.scope(
            state: \.activity,
            action: RootNavigationLogic.Action.activity
          )
        )
        .padding(.top, 52)
        .tag(RootNavigationLogic.Tab.activity)

        InboxView(
          store: store.scope(
            state: \.inbox,
            action: RootNavigationLogic.Action.inbox
          )
        )
        .padding(.top, 52)
        .tag(RootNavigationLogic.Tab.inbox)

        GodView(
          store: store.scope(
            state: \.god,
            action: RootNavigationLogic.Action.god
          )
        )
        .tag(RootNavigationLogic.Tab.god)

        ProfileView(
          store: store.scope(
            state: \.profile,
            action: RootNavigationLogic.Action.profile
          )
        )
        .padding(.top, 52)
        .tag(RootNavigationLogic.Tab.profile)

        AboutView(
          store: store.scope(
            state: \.about,
            action: RootNavigationLogic.Action.about
          )
        )
        .padding(.top, 52)
        .tag(RootNavigationLogic.Tab.about)
      }
      .ignoresSafeArea()
      .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
      .task { await store.send(.onTask).finish() }
      .overlay(alignment: .top) {
        SlideTabMenuView(
          tabItems: RootNavigationLogic.Tab.allCases,
          selection: viewStore.$selectedTab
        )
      }
      .sheet(
        store: store.scope(state: \.$friendRequestSheet, action: RootNavigationLogic.Action.friendRequestSheet)
      ) { store in
        FriendRequestSheetView(store: store)
          .presentationBackground(Color.clear)
      }
    }
  }
}
