import ComposableArchitecture
import SwiftUI

public struct ShareFeedbackHalfModalReducer: Reducer {
  public init() {}

    public struct State: Equatable {
        var urlToOpen: URL?
        public init() {}
    }

    public enum Action: Equatable {
      case shareByEmailTapped
      case shareByGmailTapped
      case copyTextTapped
    }


    // TODO: メールあれこれ
    private static let supportEmailAddress = "support@god.com"
    private static let supportEmailSubject = "お問い合わせ"
    private static let emailTemplateText = """
    Email

    Templates
    """

    public var body: some Reducer<State, Action> {
        Reduce { _, action in
          switch action {
          case .shareByEmailTapped:
              let urlString = "mailto:\(Self.supportEmailAddress)?subject=\(Self.supportEmailSubject)&body=\(Self.emailTemplateText)"

              if let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) {
                  UIApplication.shared.open(url)
              } else {

              }
              return .none
          case .shareByGmailTapped:
              let urlString = "googlegmail:///co?to=\(Self.supportEmailAddress)&subject=\(Self.supportEmailSubject)&body=\(Self.emailTemplateText)"
              if let url = URL(string: urlString) {
                  UIApplication.shared.open(url)
              }
              return .none
          case .copyTextTapped:
              UIPasteboard.general.string = Self.emailTemplateText
              return .none
          }
        }
    }
}

public struct ShareFeedbackHalfModalView: View {
  let store: StoreOf<ShareFeedbackHalfModalReducer>

  public init(store: StoreOf<ShareFeedbackHalfModalReducer>) {
    self.store = store
  }

    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(alignment: .center, spacing: 28) {
                VStack(alignment: .center, spacing: 12) {
                    Text("Email us")
                        .font(.title3)
                        .bold()
                    Text("If you need help with the app or want to share feedback, send us an email and we'll get back to you right away.")
                        .font(.body)
                        .foregroundColor(.godTextSecondaryLight)
                        .lineLimit(3)
                }
                .padding(.horizontal, 60)
                HStack(alignment: .center) {
                    Button(action: {
                        viewStore.send(.shareByEmailTapped)
                    }) {
                        VStack(alignment: .center, spacing: 8) {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.blue)
                                .frame(width: 60, height: 60)
                            Text("Mail")
                                .foregroundColor(.godBlack)
                        }
                    }
                    Spacer()
                    Button(action: {
                        viewStore.send(.shareByGmailTapped)
                    }) {
                        VStack(alignment: .center, spacing: 8) {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.blue)
                                .frame(width: 60, height: 60)
                            Text("Gmail")
                                .foregroundColor(.godBlack)
                        }
                    }
                    Spacer()
                    Button(action: {
                        viewStore.send(.copyTextTapped)
                    }) {
                        VStack(alignment: .center, spacing: 8) {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.blue)
                                .frame(width: 60, height: 60)
                            Text("Copy")
                                .foregroundColor(.godBlack)
                        }
                    }
                }
                .padding(.horizontal, 56)
                Button(action: {
                    dismiss()
                }, label: {
                    Text("Close")
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
