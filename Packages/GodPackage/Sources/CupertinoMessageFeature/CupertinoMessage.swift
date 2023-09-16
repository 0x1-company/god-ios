import ComposableArchitecture
import MessageUI
import SwiftUI
import SwiftUIMessage

public struct CupertinoMessageLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    var recipient: String
    var body: String

    public init(recipient: String, body: String) {
      self.recipient = recipient
      self.body = body
    }
  }

  public enum Action: Equatable {}

  public func reduce(into state: inout State, action: Action) -> Effect<Action> {}
}

public struct CupertinoMessageView: View {
  let store: StoreOf<CupertinoMessageLogic>

  public init(store: StoreOf<CupertinoMessageLogic>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      MessageComposeView(
        .init(
          recipients: [viewStore.recipient],
          body: viewStore.body
        )
      )
      .ignoresSafeArea()
    }
  }
}

#Preview {
  CupertinoMessageView(
    store: .init(
      initialState: CupertinoMessageLogic.State(
        recipient: "+1-111-111-1112",
        body: """
        https://godapp.jp/add/tomokisun

        Get this app
        """
      ),
      reducer: { CupertinoMessageLogic() }
    )
  )
}
