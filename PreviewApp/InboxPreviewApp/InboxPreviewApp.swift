import InboxFeature
import SwiftUI

@main
struct InboxPreviewAppApp: App {
  var body: some Scene {
    WindowGroup {
      InboxView(
        store: .init(
          initialState: InboxLogic.State(),
          reducer: { InboxLogic() }._printChanges()
        )
      )
    }
  }
}
