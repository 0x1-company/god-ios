import ComposableArchitecture
import GodFeature
import SwiftUI

@main
struct CashOutPreviewAppApp: App {
  var body: some Scene {
    WindowGroup {
      NavigationStack {
        CashOutView(
          store: .init(
            initialState: CashOutReducer.State(),
            reducer: { CashOutReducer()._printChanges() }
          )
        )
      }
    }
  }
}
