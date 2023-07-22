import SwiftUI
import InboxFeature

@main
struct InboxPreviewAppApp: App {
  var body: some Scene {
    WindowGroup {
      InboxView(
        store: .init(
          initialState: InboxReducer.State(),
          reducer: InboxReducer()._printChanges()
        )
      )
    }
  }
}
