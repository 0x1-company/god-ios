import ComposableArchitecture
import GodFeature
import SwiftUI

@main
struct GodPreviewAppApp: App {
  var body: some Scene {
    WindowGroup {
      VoteView(
        store: .init(
          initialState: VoteReducer.State(),
          reducer: VoteReducer()._printChanges()
        )
      )
    }
  }
}
