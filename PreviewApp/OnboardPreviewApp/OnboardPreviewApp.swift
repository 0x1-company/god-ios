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
        UsernameSettingView(
          store: .init(
            initialState: UsernameSettingReducer.State(),
            reducer: UsernameSettingReducer()._printChanges()
          )
        )
      }
    }
  }
}
