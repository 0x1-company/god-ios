import AboutFeature
import ActivityFeature
import AddFeature
import ComposableArchitecture
import GodFeature
import InboxFeature
import ProfileFeature
import SwiftUI

public struct RootNavigationReducer: Reducer {
  public init() {}

  public struct State: Equatable {
    var add = AddReducer.State()
    var activity = ActivityReducer.State()
    var inbox = InboxReducer.State()
    var question = QuestionReducer.State()
    var profile = ProfileReducer.State()
    var about = AboutReducer.State()
    public init() {}
  }

  public enum Action: Equatable {
    case add(AddReducer.Action)
    case activity(ActivityReducer.Action)
    case inbox(InboxReducer.Action)
    case question(QuestionReducer.Action)
    case profile(ProfileReducer.Action)
    case about(AboutReducer.Action)
  }

  public var body: some Reducer<State, Action> {
    Scope(state: \.add, action: /Action.add) {
      AddReducer()
    }
    Scope(state: \.activity, action: /Action.activity) {
      ActivityReducer()
    }
    Scope(state: \.inbox, action: /Action.inbox) {
      InboxReducer()
    }
    Scope(state: \.question, action: /Action.question) {
      QuestionReducer()
    }
    Scope(state: \.profile, action: /Action.profile) {
      ProfileReducer()
    }
    Scope(state: \.about, action: /Action.about) {
      AboutReducer()
    }
  }
}

public struct RootNavigationView: View {
  let store: StoreOf<RootNavigationReducer>

  public init(store: StoreOf<RootNavigationReducer>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { _ in
      TabView {
        AddView(
          store: store.scope(
            state: \.add,
            action: RootNavigationReducer.Action.add
          )
        )

        ActivityView(
          store: store.scope(
            state: \.activity,
            action: RootNavigationReducer.Action.activity
          )
        )

        InboxView(
          store: store.scope(
            state: \.inbox,
            action: RootNavigationReducer.Action.inbox
          )
        )

        QuestionView(
          store: store.scope(
            state: \.question,
            action: RootNavigationReducer.Action.question
          )
        )

        ProfileView(
          store: store.scope(
            state: \.profile,
            action: RootNavigationReducer.Action.profile
          )
        )

        AboutView(
          store: store.scope(
            state: \.about,
            action: RootNavigationReducer.Action.about
          )
        )
      }
      .ignoresSafeArea()
      .tabViewStyle(.page)
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
