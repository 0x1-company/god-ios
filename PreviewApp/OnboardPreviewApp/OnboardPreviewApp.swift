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
        LastNameSettingView(
          store: .init(
            initialState: LastNameSettingReducer.State(),
            reducer: LastNameSettingReducer()._printChanges()
          )
        )
      }
    }
  }
}
