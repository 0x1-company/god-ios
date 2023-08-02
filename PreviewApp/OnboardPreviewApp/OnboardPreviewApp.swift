import OnboardFeature
import SwiftUI

@main
struct MyApp: App {
  var body: some Scene {
    WindowGroup {
      NavigationStack {
        FirstNameSettingView(
          store: .init(
            initialState: FirstNameSettingReducer.State(),
            reducer: { FirstNameSettingReducer()._printChanges() }
          )
        )
      }
    }
  }
}
