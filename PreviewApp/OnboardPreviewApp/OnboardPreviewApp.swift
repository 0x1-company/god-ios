import SwiftUI
import OnboardFeature

@main
struct MyApp: App {
  var body: some Scene {
    WindowGroup {
//      WelcomeView(
//        store: .init(
//          initialState: WelcomeReducer.State(),
//          reducer: WelcomeReducer().
//        )
//      )
      NavigationStack {
        FirstNameSettingView(
          store: .init(
            initialState: FirstNameSettingReducer.State(),
            reducer: FirstNameSettingReducer()._printChanges()
          )
        )
      }
    }
  }
}
