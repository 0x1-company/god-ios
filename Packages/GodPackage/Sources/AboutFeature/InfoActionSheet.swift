import ButtonStyles
import ComposableArchitecture
import GodActionSheet
import SwiftUI

public struct InfoActionSheetLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    let title: String
  }

  public enum Action: Equatable {
    case onTask
    case closeButtonTapped
  }

  public var body: some Reducer<State, Action> {
    Reduce<State, Action> { _, action in
      switch action {
      case .onTask:
        return .none

      case .closeButtonTapped:
        return .none
      }
    }
  }
}

public struct InfoActionSheetView: View {
  let store: StoreOf<InfoActionSheetLogic>

  public init(store: StoreOf<InfoActionSheetLogic>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      GodActionSheet(
        title: viewStore.title,
        description: "If you need help with the app or want to\nshare feedback, send us an email and\nwe will get back to you right away.",
        onDismiss: {
          viewStore.send(.closeButtonTapped)
        },
        actions: {
          HStack(spacing: 0) {
            Spacer()

            Button {} label: {
              VStack(alignment: .center, spacing: 8) {
                RoundedRectangle(cornerRadius: 8)
                  .fill(Color.blue)
                  .frame(width: 60, height: 60)
                Text("Mail", bundle: .module)
                  .foregroundColor(.godBlack)
              }
            }

            Spacer()

            Button {} label: {
              VStack(alignment: .center, spacing: 8) {
                RoundedRectangle(cornerRadius: 8)
                  .fill(Color.blue)
                  .frame(width: 60, height: 60)
                Text("Gmail", bundle: .module)
                  .foregroundColor(.godBlack)
              }
            }

            Spacer()

            Button {} label: {
              VStack(alignment: .center, spacing: 8) {
                RoundedRectangle(cornerRadius: 8)
                  .fill(Color.gray)
                  .frame(width: 60, height: 60)
                  .overlay {
                    Image(systemName: "doc.on.doc")
                      .tint(Color.white)
                      .font(.title)
                  }
                Text("Copy", bundle: .module)
                  .foregroundColor(.godBlack)
              }
            }

            Spacer()
          }
          .buttonStyle(HoldDownButtonStyle())
        }
      )
    }
  }
}

#Preview {
  InfoActionSheetView(
    store: .init(
      initialState: InfoActionSheetLogic.State(
        title: "Email us"
      ),
      reducer: { InfoActionSheetLogic() }
    )
  )
}
