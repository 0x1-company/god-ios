import SwiftUI
import ComposableArchitecture
import OnboardFeature

@main
struct MyApp: App {
  var body: some Scene {
    WindowGroup {
      WelcomeView(
        store: .init(
          initialState: WelcomeReducer.State(),
          reducer: WelcomeReducer()._printChanges()
        )
      )
    }
  }
}
