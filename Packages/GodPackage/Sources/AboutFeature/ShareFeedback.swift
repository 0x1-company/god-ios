import Colors
import ComposableArchitecture
import SwiftUI

public struct ShareFeedbackLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    public init() {}
  }

  public enum Action: Equatable {
    case shareByEmailButtonTapped
    case shareByGmailButtonTapped
    case copyTextButtonTapped
    case closeButtonTapped
  }

  @Dependency(\.dismiss) var dismiss
  @Dependency(\.openURL) var openURL

  // TODO: メールあれこれ
  private static let supportEmailAddress = "support@god.com"
  private static let supportEmailSubject = "お問い合わせ"
  private static let emailTemplateText = """
  Email

  Templates
  """

  public var body: some Reducer<State, Action> {
    Reduce<State, Action> { _, action in
      switch action {
      case .shareByEmailButtonTapped:
        let urlString = "mailto:\(Self.supportEmailAddress)?subject=\(Self.supportEmailSubject)&body=\(Self.emailTemplateText)"
        guard let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
        else { return .none }
        return .run { _ in
          await openURL(url)
        }
      case .shareByGmailButtonTapped:
        let urlString = "googlegmail:///co?to=\(Self.supportEmailAddress)&subject=\(Self.supportEmailSubject)&body=\(Self.emailTemplateText)"
        guard let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
        else { return .none }
        return .run { _ in
          await openURL(url)
        }
      case .copyTextButtonTapped:
        UIPasteboard.general.string = Self.emailTemplateText
        return .none
      case .closeButtonTapped:
        return .run { _ in
          await dismiss()
        }
      }
    }
  }
}

public struct ShareFeedback: View {
  static let heightForPresentationDetents: CGFloat = 320
  let store: StoreOf<ShareFeedbackLogic>

  public init(store: StoreOf<ShareFeedbackLogic>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      VStack(alignment: .center, spacing: 28) {
        VStack(alignment: .center, spacing: 12) {
          Text(String(localized: "Email us", bundle: .module))
            .font(.title3)
            .bold()
          Text(
            String(
              localized: "If you need help with the app or want to share feedback, send us an email and we'll get back to you right away.",
              bundle: .module
            )
          )
          .font(.body)
          .foregroundColor(.godTextSecondaryLight)
          .lineLimit(3)
        }
        .padding(.horizontal, 60)
        HStack(alignment: .center) {
          Button(action: {
            viewStore.send(.shareByEmailButtonTapped)
          }) {
            VStack(alignment: .center, spacing: 8) {
              RoundedRectangle(cornerRadius: 8)
                .fill(Color.blue)
                .frame(width: 60, height: 60)
              Text(String(localized: "Mail", bundle: .module))
                .foregroundColor(.godBlack)
            }
          }
          Spacer()
          Button(action: {
            viewStore.send(.shareByGmailButtonTapped)
          }) {
            VStack(alignment: .center, spacing: 8) {
              RoundedRectangle(cornerRadius: 8)
                .fill(Color.blue)
                .frame(width: 60, height: 60)
              Text(String(localized: "Gmail", bundle: .module))
                .foregroundColor(.godBlack)
            }
          }
          Spacer()
          Button(action: {
            viewStore.send(.copyTextButtonTapped)
          }) {
            VStack(alignment: .center, spacing: 8) {
              RoundedRectangle(cornerRadius: 8)
                .fill(Color.blue)
                .frame(width: 60, height: 60)
              Text(String(localized: "Copy", bundle: .module))
                .foregroundColor(.godBlack)
            }
          }
        }
        .padding(.horizontal, 56)
        Button(action: {
          viewStore.send(.closeButtonTapped)
        }, label: {
          Text(String(localized: "Close", bundle: .module))
            .font(.body)
            .foregroundColor(.godBlack)
            .frame(height: 48)
            .frame(maxWidth: .infinity)
            .overlay(
              RoundedRectangle(cornerRadius: 24)
                .stroke(Color.black, lineWidth: 1)
            )
        })
        .padding(.horizontal, 16)
      }
    }
  }
}
