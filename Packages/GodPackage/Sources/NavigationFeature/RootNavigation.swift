import ComposableArchitecture
import SwiftUI
import InboxFeature
import GodFeature
import ProfileFeature
import AboutFeature

public struct RootNavigationReducer: ReducerProtocol {
  public init() {}
  
  public struct State: Equatable {
    var inbox = InboxReducer.State()
    var question = QuestionReducer.State()
    var profile = ProfileReducer.State()
    var about = AboutReducer.State()
    public init() {}
  }
  
  public enum Action: Equatable {
    case inbox(InboxReducer.Action)
    case question(QuestionReducer.Action)
    case profile(ProfileReducer.Action)
    case about(AboutReducer.Action)
  }
  
  public var body: some ReducerProtocol<State, Action> {
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
    WithViewStore(store, observe: { $0 }) { viewStore in
      TabView {
        InboxView(
          store: store.scope(
            state: \.inbox,
            action: RootNavigationReducer.Action.inbox
          )
        )
        .tabItem {
          Text("Inbox")
        }

        QuestionView(
          store: store.scope(
            state: \.question,
            action: RootNavigationReducer.Action.question
          )
        )
        .tabItem {
          Text("God")
        }

        ProfileView(
          store: store.scope(
            state: \.profile,
            action: RootNavigationReducer.Action.profile
          )
        )
        .tabItem {
          Text("Profile")
        }

        AboutView(
          store: store.scope(
            state: \.about,
            action: RootNavigationReducer.Action.about
          )
        )
        .tabItem {
          Text("About")
        }
      }
    }
  }
}

struct RootNavigationViewPreviews: PreviewProvider {
  static var previews: some View {
    RootNavigationView(
      store: .init(
        initialState: RootNavigationReducer.State(),
        reducer: RootNavigationReducer()
      )
    )
  }
}
