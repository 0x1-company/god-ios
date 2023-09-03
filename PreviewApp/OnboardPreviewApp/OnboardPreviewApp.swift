import OnboardFeature
import SwiftUI

@main
struct MyApp: App {
  var body: some Scene {
    WindowGroup {
      OnboardView(
        store: .init(
          initialState: OnboardLogic.State(),
          reducer: { OnboardLogic()._printChanges() }
        )
      )
    }
  }
}
