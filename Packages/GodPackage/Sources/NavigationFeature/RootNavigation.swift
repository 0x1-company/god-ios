import AboutFeature
import ActivityFeature
import AddFeature
import ComposableArchitecture
import GodFeature
import InboxFeature
import ProfileFeature
import SwiftUI

public struct RootNavigationLogic: Reducer {
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
    var add = AddLogic.State()
    var activity = ActivityLogic.State()
    var inbox = InboxLogic.State()
    var god = GodLogic.State()
    var profile = ProfileLogic.State()
    var about = AboutLogic.State()
    @BindingState var selectedTab = Tab.god
    public init() {}
  }

  public enum Action: Equatable, BindableAction {
    case add(AddLogic.Action)
    case activity(ActivityLogic.Action)
    case inbox(InboxLogic.Action)
    case god(GodLogic.Action)
    case profile(ProfileLogic.Action)
    case about(AboutLogic.Action)
    case binding(BindingAction<State>)
  }

  public var body: some Reducer<State, Action> {
    BindingReducer()
    Scope(state: \.add, action: /Action.add, child: AddLogic.init)
    Scope(state: \.activity, action: /Action.activity, child: ActivityLogic.init)
    Scope(state: \.inbox, action: /Action.inbox, child: InboxLogic.init)
    Scope(state: \.god, action: /Action.god, child: GodLogic.init)
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
      .overlay(alignment: .top) {
        SlideTabMenuView(
          tabItems: RootNavigationLogic.Tab.allCases,
          selection: viewStore.$selectedTab
        )
      }
    }
  }
}

extension RootNavigationView {
  struct SlideTabMenuView: View {
    let tabItems: [RootNavigationLogic.Tab]
    @Binding var selection: RootNavigationLogic.Tab

    var before: RootNavigationLogic.Tab? {
      Array(tabItems.enumerated())
        .first(where: { $0.element == selection })
        .map { $0.offset == tabItems.startIndex ? nil : tabItems[$0.offset - 1] }
        ?? nil
    }

    var after: RootNavigationLogic.Tab? {
      Array(tabItems.enumerated())
        .first(where: { $0.element == selection })
        .map { $0.offset + 1 == tabItems.endIndex ? nil : tabItems[$0.offset + 1] }
        ?? nil
    }

    var body: some View {
      GeometryReader { geometry in
        HStack(spacing: 0) {
          Button(before?.rawValue ?? "") {
            withAnimation(.default) {
              selection = before ?? selection
            }
          }
          .frame(width: geometry.size.width / 3, alignment: .leading)
          .buttonStyle(TabButtonStyle(isSelected: false))

          Button(selection.rawValue) {}
            .frame(width: geometry.size.width / 3)
            .buttonStyle(TabButtonStyle(isSelected: true))

          Button(after?.rawValue ?? "") {
            withAnimation(.default) {
              selection = after ?? selection
            }
          }
          .frame(width: geometry.size.width / 3, alignment: .trailing)
          .buttonStyle(TabButtonStyle(isSelected: false))
        }
        .frame(height: 52)
        .frame(maxWidth: .infinity)
      }
    }

    struct TabButtonStyle: ButtonStyle {
      let isSelected: Bool
      func makeBody(configuration: Configuration) -> some View {
        configuration.label
          .foregroundStyle(isSelected ? Color.black : Color.secondary)
          .font(.system(size: 18, weight: .bold, design: .rounded))
          .padding(.horizontal, 16)
          .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
          .animation(.default, value: configuration.isPressed)
      }
    }
  }
}
