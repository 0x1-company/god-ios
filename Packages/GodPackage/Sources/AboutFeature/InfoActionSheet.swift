import ButtonStyles
import ComposableArchitecture
import Constants
import GodActionSheet
import SwiftUI
import UIPasteboardClient

public struct InfoActionSheetLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    let title: String
  }

  public enum Action: Equatable {
    case onTask
    case closeButtonTapped
    case mailButtonTapped
    case gmailButtonTapped
    case copyButtonTapped
  }

  @Dependency(\.openURL) var openURL
  @Dependency(\.dismiss) var dismiss
  @Dependency(\.pasteboard) var pasteboard

  public var body: some Reducer<State, Action> {
    Reduce<State, Action> { state, action in
      switch action {
      case .onTask:
        return .none

      case .closeButtonTapped:
        return .run { _ in
          await dismiss()
        }

      case .mailButtonTapped:
        guard let url = mailGenerator(subject: state.title)
        else { return .none }
        return .run { _ in
          await openURL(url)
          await dismiss()
        }

      case .gmailButtonTapped:
        guard let url = gmailGenerator(subject: state.title)
        else { return .none }
        return .run { _ in
          await openURL(url)
          await dismiss()
        }

      case .copyButtonTapped:
        pasteboard.string(Constants.helpEmailAddress)
        return .none
      }
    }
  }

  private func mailGenerator(subject: String) -> URL? {
    var components = URLComponents()
    components.scheme = "mailto"
    components.path = "\(Constants.helpEmailAddress)"
    components.queryItems = [
      URLQueryItem(name: "subject", value: subject),
      URLQueryItem(
        name: "body",
        value: String(
          localized: """
          Please describe your problem or feedback. Attach screenshots if necessary.
          -----TYPE BELOW THIS LINE-----
          """,
          bundle: .module
        )
      ),
    ]
    return components.url
  }

  private func gmailGenerator(subject: String) -> URL? {
    var components = URLComponents()
    components.scheme = "googlegmail"
    components.path = "/co"
    components.queryItems = [
      URLQueryItem(name: "to", value: Constants.helpEmailAddress),
      URLQueryItem(name: "subject", value: subject),
      URLQueryItem(
        name: "body",
        value: String(
          localized: """
          Please describe your problem or feedback. Attach screenshots if necessary.
          -----TYPE BELOW THIS LINE-----
          """,
          bundle: .module
        )
      ),
    ]
    return components.url
  }
}

public struct InfoActionSheetView: View {
  let store: StoreOf<InfoActionSheetLogic>
  @Environment(\.displayScale) var displayScale

  public init(store: StoreOf<InfoActionSheetLogic>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      GodActionSheet(
        title: viewStore.title,
        description: String(
          localized: "If you need help with the app or want to\nshare feedback, send us an email and\nwe will get back to you right away.",
          bundle: .module
        ),
        onDismiss: {
          viewStore.send(.closeButtonTapped)
        },
        actions: {
          HStack(spacing: 0) {
            Spacer()

            Button {
              store.send(.mailButtonTapped)
            } label: {
              VStack(alignment: .center, spacing: 8) {
                RoundedRectangle(cornerRadius: 12)
                  .stroke(Color.secondary, lineWidth: 1 / displayScale)
                  .frame(width: 60, height: 60)
                  .overlay {
                    Image(ImageResource.mail)
                      .resizable()
                      .aspectRatio(contentMode: .fit)
                      .cornerRadius(12)
                  }

                Text("Mail", bundle: .module)
                  .bold()
                  .foregroundColor(.godBlack)
              }
            }

            Spacer()

            Button {
              store.send(.gmailButtonTapped)
            } label: {
              VStack(alignment: .center, spacing: 8) {
                RoundedRectangle(cornerRadius: 12)
                  .stroke(Color.secondary, lineWidth: 1 / displayScale)
                  .frame(width: 60, height: 60)
                  .overlay {
                    Image(ImageResource.gmail)
                      .resizable()
                      .aspectRatio(contentMode: .fit)
                  }
                Text("Gmail", bundle: .module)
                  .bold()
                  .foregroundColor(.godBlack)
              }
            }

            Spacer()

            Button {
              store.send(.copyButtonTapped)
            } label: {
              VStack(alignment: .center, spacing: 8) {
                RoundedRectangle(cornerRadius: 8)
                  .fill(Color.gray)
                  .frame(width: 60, height: 60)
                  .overlay {
                    Image(systemName: "doc.on.doc")
                      .font(.title)
                      .foregroundStyle(Color.white)
                  }
                Text("Copy", bundle: .module)
                  .bold()
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
