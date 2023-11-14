import AnalyticsClient
import ComposableArchitecture
import Constants
import Styleguide
import SwiftUI
import UIPasteboardClient

@Reducer
public struct EmailSheetLogic {
  public init() {}

  public struct State: Equatable {
    let title: String

    public init(title: String) {
      self.title = title
    }
  }

  public enum Action: Equatable {
    case onTask
    case dismissButtonTapped
    case mailButtonTapped
    case gmailButtonTapped
    case copyButtonTapped
  }

  @Dependency(\.openURL) var openURL
  @Dependency(\.dismiss) var dismiss
  @Dependency(\.analytics) var analytics
  @Dependency(\.pasteboard) var pasteboard

  public var body: some Reducer<State, Action> {
    Reduce<State, Action> { state, action in
      switch action {
      case .onTask:
        analytics.logScreen(screenName: "EmailSheet", of: self)
        return .none

      case .dismissButtonTapped:
        return .run { _ in
          await dismiss()
        }

      case .mailButtonTapped:
        analytics.buttonClick(name: .email, parameters: [
          "subject": state.title,
          "title": String(localized: "Mail", bundle: .module),
        ])
        guard let url = generateEmail(subject: state.title)
        else { return .none }
        return .run { _ in
          await openURL(url)
          await dismiss()
        }

      case .gmailButtonTapped:
        analytics.buttonClick(name: .gmail, parameters: [
          "subject": state.title,
          "title": String(localized: "Gmail", bundle: .module),
        ])
        guard let url = generateGmail(subject: state.title)
        else { return .none }
        return .run { _ in
          await openURL(url)
          await dismiss()
        }

      case .copyButtonTapped:
        pasteboard.string(Constants.helpEmailAddress)
        analytics.buttonClick(name: .copyLink, parameters: [
          "subject": state.title,
          "title": String(localized: "Copy", bundle: .module),
        ])
        return .none
      }
    }
  }

  private func generateEmail(subject: String) -> URL? {
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

  private func generateGmail(subject: String) -> URL? {
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

public struct EmailSheetView: View {
  let store: StoreOf<EmailSheetLogic>
  @Environment(\.displayScale) var displayScale

  public init(store: StoreOf<EmailSheetLogic>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      VStack {
        Color.clear
          .contentShape(Rectangle())
          .onTapGesture {
            store.send(.dismissButtonTapped)
          }

        VStack(spacing: 24) {
          VStack(spacing: 12) {
            Text(viewStore.title)
              .font(.system(.title3, design: .rounded, weight: .bold))

            Text("If you need help with the app or want to share feedback, send us an email and we will get back to you right away.", bundle: .module)
              .foregroundStyle(.secondary)
              .font(.system(.footnote, design: .rounded))
          }

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
                  .foregroundStyle(Color.godBlack)
                  .font(.system(.body, design: .rounded, weight: .bold))
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
                  .foregroundStyle(Color.godBlack)
                  .font(.system(.body, design: .rounded, weight: .bold))
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
                  .foregroundStyle(Color.godBlack)
                  .font(.system(.body, design: .rounded, weight: .bold))
              }
            }

            Spacer()
          }
          .buttonStyle(HoldDownButtonStyle())

          Button {
            store.send(.dismissButtonTapped)
          } label: {
            RoundedRectangle(cornerRadius: 24)
              .stroke(Color.black, lineWidth: 1)
              .frame(height: 48)
              .background {
                Text("Close", bundle: .module)
                  .foregroundStyle(.black)
                  .frame(height: 48)
                  .frame(maxWidth: .infinity)
                  .font(.system(.body, design: .rounded, weight: .bold))
              }
          }
          .buttonStyle(HoldDownButtonStyle())
        }
        .padding(.top, 18)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .multilineTextAlignment(.center)
      }
      .task { await store.send(.onTask).finish() }
    }
  }
}

#Preview {
  Color.red
    .ignoresSafeArea()
    .sheet(isPresented: .constant(true)) {
      EmailSheetView(
        store: .init(
          initialState: EmailSheetLogic.State(
            title: "Email us"
          ),
          reducer: { EmailSheetLogic() }
        )
      )
      .presentationBackground(Color.clear)
    }
}
