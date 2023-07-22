import SwiftUI
import ComposableArchitecture
import InboxFeature
import AboutFeature
import GodFeature

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
        
        GodView(
          store: .init(
            initialState: GodReducer.State(),
            reducer: GodReducer()._printChanges()
          )
        )
        
        AboutView(
          store: .init(
            initialState: AboutReducer.State(),
            reducer: AboutReducer()._printChanges()
          )
        )
      }
    }
  }
}
