import Colors
import ComposableArchitecture
import SwiftUI

public struct AddMySchoolToMyProfileReducer: Reducer {
  public init() {}

    public struct State: Equatable {
        var urlToOpen: URL?
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
        Reduce { _, action in
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

public struct AddMySchoolToMyProfileView: View {
  let store: StoreOf<AddMySchoolToMyProfileReducer>

  public init(store: StoreOf<AddMySchoolToMyProfileReducer>) {
    self.store = store
  }

    @Environment(\.dismiss) private var dismiss

    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(alignment: .center, spacing: 28) {
                VStack(alignment: .center, spacing: 12) {
                    Text("Add my school to my profile")
                        .font(.title3)
                        .bold()
                    Text("For help with this, send us an email and we’ll get back to you right away.")
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
                            Text("Mail")
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
                            Text("Gmail")
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
