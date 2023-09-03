import AboutFeature
import ActivityFeature
import AddFeature
import ComposableArchitecture
import GodFeature
import InboxFeature
import PollFeature
import ProfileFeature
import SwiftUI

public struct RootNavigationLogic: Reducer {
  public init() {}

  public enum Tab: Equatable {
    case add
    case activity
    case inbox
    case poll
    case profile
    case about
  }

  public struct State: Equatable {
    var add = AddLogic.State()
    var activity = ActivityLogic.State()
    var inbox = InboxLogic.State()
    var poll = PollLogic.State()
    var profile = ProfileLogic.State()
    var about = AboutLogic.State()
    @BindingState var selectedTab = Tab.poll
    public init() {}
  }

  public enum Action: Equatable, BindableAction {
    case add(AddLogic.Action)
    case activity(ActivityLogic.Action)
    case inbox(InboxLogic.Action)
    case poll(PollLogic.Action)
    case profile(ProfileLogic.Action)
    case about(AboutLogic.Action)
    case binding(BindingAction<State>)
  }

  public var body: some Reducer<State, Action> {
    BindingReducer()
    Scope(state: \.add, action: /Action.add, child: AddLogic.init)
    Scope(state: \.activity, action: /Action.activity, child: ActivityLogic.init)
    Scope(state: \.inbox, action: /Action.inbox, child: InboxLogic.init)
    Scope(state: \.poll, action: /Action.poll, child: PollLogic.init)
    Scope(state: \.profile, action: /Action.profile, child: ProfileLogic.init)
    Scope(state: \.about, action: /Action.about, child: AboutLogic.init)
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
        .tag(RootNavigationLogic.Tab.add)

        ActivityView(
          store: store.scope(
            state: \.activity,
            action: RootNavigationLogic.Action.activity
          )
        )
        .tag(RootNavigationLogic.Tab.activity)

        InboxView(
          store: store.scope(
            state: \.inbox,
            action: RootNavigationLogic.Action.inbox
          )
        )
        .tag(RootNavigationLogic.Tab.inbox)

        PollView(
          store: store.scope(
            state: \.poll,
            action: RootNavigationLogic.Action.poll
          )
        )
        .tag(RootNavigationLogic.Tab.poll)

        ProfileView(
          store: store.scope(
            state: \.profile,
            action: RootNavigationLogic.Action.profile
          )
        )
        .tag(RootNavigationLogic.Tab.profile)

        AboutView(
          store: store.scope(
            state: \.about,
            action: RootNavigationLogic.Action.about
          )
        )
        .tag(RootNavigationLogic.Tab.about)
      }
      .ignoresSafeArea()
      .tabViewStyle(.page(indexDisplayMode: .never))
    }
  }
}

struct RootNavigationViewPreviews: PreviewProvider {
  static var previews: some View {
    RootNavigationView(
      store: .init(
        initialState: RootNavigationLogic.State(),
        reducer: { RootNavigationLogic() }
      )
    )
  }
}
