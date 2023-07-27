import SwiftUI
import ComposableArchitecture
import GodFeature

@main
struct GodPreviewAppApp: App {
  var body: some Scene {
    WindowGroup {
      QuestionView(
        store: .init(
          initialState: QuestionReducer.State(),
          reducer: QuestionReducer()._printChanges()
        )
      )
    }
  }
}
