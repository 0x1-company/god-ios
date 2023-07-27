import AboutFeature
import ComposableArchitecture
import GodFeature
import InboxFeature
import ProfileFeature
import SwiftUI

@main
struct GodApp: App {
  var body: some Scene {
    WindowGroup {
      TabView {
        InboxView(
          store: .init(
            initialState: InboxReducer.State(),
            reducer: InboxReducer()._printChanges()
          )
        )
        .tabItem {
          Text("Inbox")
        }

        VoteView(
          store: .init(
            initialState: VoteReducer.State(),
            reducer: VoteReducer()._printChanges()
          )
        )
        .tabItem {
          Text("God")
        }

        ProfileView(
          store: .init(
            initialState: ProfileReducer.State(),
            reducer: ProfileReducer()._printChanges()
          )
        )
        .tabItem {
          Text("Profile")
        }

        AboutView(
          store: .init(
            initialState: AboutReducer.State(),
            reducer: AboutReducer()._printChanges()
          )
        )
        .tabItem {
          Text("About")
        }
      }
    }
  }
}
