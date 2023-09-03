import ComposableArchitecture
import GodFeature
import SwiftUI

@main
struct GodPreviewAppApp: App {
  var body: some Scene {
    WindowGroup {
      VoteView(
        store: .init(
          initialState: VoteLogic.State(),
          reducer: { VoteLogic() }._printChanges()
        )
      )
    }
  }
}
