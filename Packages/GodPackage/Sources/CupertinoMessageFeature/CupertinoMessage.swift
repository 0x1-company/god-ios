import ComposableArchitecture
import MessageUI
import SwiftUI
import SwiftUIMessage

@Reducer
public struct CupertinoMessageLogic {
  public init() {}

  public struct State: Equatable {
    var recipients: [String]
    var body: String

    public init(recipient: String, body: String) {
      recipients = [recipient]
      self.body = body
    }

    public init(recipients: [String], body: String) {
      self.recipients = recipients
      self.body = body
    }
  }

  public enum Action {}

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
          recipients: viewStore.recipients,
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
        body: "https://godapp.jp/add/tomokisun\n\nGet this app"
      ),
      reducer: { CupertinoMessageLogic() }
    )
  )
}
