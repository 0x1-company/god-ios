import AboutFeature
import ActivityFeature
import AddFeature
import ComposableArchitecture
import GodFeature
import InboxFeature
import PollFeature
import ProfileFeature
import SwiftUI

public struct RootNavigationReducer: Reducer {
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
    var add = AddReducer.State()
    var activity = ActivityReducer.State()
    var inbox = InboxReducer.State()
    var poll = PollReducer.State()
    var profile = ProfileReducer.State()
    var about = AboutReducer.State()
    @BindingState var selectedTab = Tab.poll
    public init() {}
  }

  public enum Action: Equatable, BindableAction {
    case add(AddReducer.Action)
    case activity(ActivityReducer.Action)
    case inbox(InboxReducer.Action)
    case poll(PollReducer.Action)
    case profile(ProfileReducer.Action)
    case about(AboutReducer.Action)
    case binding(BindingAction<State>)
  }

  public var body: some Reducer<State, Action> {
    BindingReducer()
    Scope(state: \.add, action: /Action.add, child: AddReducer.init)
    Scope(state: \.activity, action: /Action.activity, child: ActivityReducer.init)
    Scope(state: \.inbox, action: /Action.inbox, child: InboxReducer.init)
    Scope(state: \.poll, action: /Action.poll, child: PollReducer.init)
    Scope(state: \.profile, action: /Action.profile, child: ProfileReducer.init)
    Scope(state: \.about, action: /Action.about, child: AboutReducer.init)
  }
}

public struct RootNavigationView: View {
  let store: StoreOf<RootNavigationReducer>

  public init(store: StoreOf<RootNavigationReducer>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      TabView(selection: viewStore.$selectedTab) {
        AddView(
          store: store.scope(
            state: \.add,
            action: RootNavigationReducer.Action.add
          )
        )
        .tag(RootNavigationReducer.Tab.add)

        ActivityView(
          store: store.scope(
            state: \.activity,
            action: RootNavigationReducer.Action.activity
          )
        )
        .tag(RootNavigationReducer.Tab.activity)

        InboxView(
          store: store.scope(
            state: \.inbox,
            action: RootNavigationReducer.Action.inbox
          )
        )
        .tag(RootNavigationReducer.Tab.inbox)

        PollView(
          store: store.scope(
            state: \.poll,
            action: RootNavigationReducer.Action.poll
          )
        )
        .tag(RootNavigationReducer.Tab.poll)

        ProfileView(
          store: store.scope(
            state: \.profile,
            action: RootNavigationReducer.Action.profile
          )
        )
        .tag(RootNavigationReducer.Tab.profile)

        AboutView(
          store: store.scope(
            state: \.about,
            action: RootNavigationReducer.Action.about
          )
        )
        .tag(RootNavigationReducer.Tab.about)
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
        initialState: RootNavigationReducer.State(),
        reducer: { RootNavigationReducer() }
      )
    )
  }
}
