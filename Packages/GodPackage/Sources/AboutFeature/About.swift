import ComposableArchitecture
import Constants
import SwiftUI
import Colors

public struct AboutReducer: Reducer {
  public init() {}

  public struct State: Equatable {
    @PresentationState var confirmationDialog: ConfirmationDialogState<Action.ConfirmationDialog>?
    var isShareFeedbackHalfModalPresented: Bool = false
    public init() {}
  }

  public enum Action: Equatable {
    case howItWorksButtonTapped
    case faqButtonTapped
    case shareFeedbackButtonTapped
    case shareFeedbackHalfModalStateChanged(Bool)
    case getHelpButtonTapped
    case safetyCenterButtonTapped
    case confirmationDialog(PresentationAction<ConfirmationDialog>)

    public enum ConfirmationDialog: Equatable {
      case addMySchoolToMyProfile
      case changeMyGrade
      case changeMyName
      case changeMyGender
      case deleteMyAccount
      case purchasesAndGodMode
      case reportBug
      case somethingElse
    }
  }

  public var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .howItWorksButtonTapped:
        return .none

      case .faqButtonTapped:
        return .none

      case .shareFeedbackButtonTapped:
          state.isShareFeedbackHalfModalPresented = true
          return .none
      case let .shareFeedbackHalfModalStateChanged(isPresented):
          state.isShareFeedbackHalfModalPresented = isPresented
          return .none
      case .getHelpButtonTapped:
        state.confirmationDialog = .faq
        return .none

      case .safetyCenterButtonTapped:
        return .none

      case let .confirmationDialog(.presented(action)):
        switch action {
        case .addMySchoolToMyProfile:
          return .none
        case .changeMyGrade:
          return .none
        case .changeMyGender:
          return .none
        case .changeMyName:
          return .none
        case .deleteMyAccount:
          return .none
        case .purchasesAndGodMode:
          return .none
        case .reportBug:
          return .none
        case .somethingElse:
          return .none
        }
      case .confirmationDialog:
        return .none
      }
    }
  }
}

public struct AboutView: View {
  let store: StoreOf<AboutReducer>

  public init(store: StoreOf<AboutReducer>) {
    self.store = store
  }

    @State private var isPresented: Bool = false
  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      VStack(spacing: 32) {
        VStack(alignment: .center, spacing: 24) {
          IconButton("How It Works", name: "") {
            viewStore.send(.howItWorksButtonTapped)
          }
          IconButton("FAQ", name: "clipboard") {
            viewStore.send(.faqButtonTapped)
          }
          IconButton("Share Feedback", name: "megaphone") {
            viewStore.send(.shareFeedbackButtonTapped)
              isPresented = true
          }
          IconButton("Get Help", name: "rescue-workers-helmet") {
            viewStore.send(.getHelpButtonTapped)
          }
          IconButton("Safety Center", name: "shield") {
            viewStore.send(.safetyCenterButtonTapped)
          }
        }
        .padding(.top, 24)
        .padding(.horizontal, 32)

        Spacer()

        HStack(spacing: 16) {
            Link(destination: Constants.instagramURL) {
                Image("instagram", bundle: .module)
                    .resizable()
                    .frame(width: 62, height: 62)
            }
          Link(destination: Constants.xURL) {
            Image("x", bundle: .module)
              .resizable()
              .frame(width: 62, height: 62)
              .clipShape(Circle())
          }
          Link(destination: Constants.tiktokURL) {
            Image("tiktok", bundle: .module)
              .resizable()
              .frame(width: 62, height: 62)
          }
        }
        .aspectRatio(contentMode: .fit)

        VStack(spacing: 0) {
          Text("God")
          Text("Terms / Privacy")
        }
        .foregroundColor(.secondary)
      }
      .confirmationDialog(
        store: store.scope(
          state: \.$confirmationDialog,
          action: { .confirmationDialog($0) }
        )
      )
//      .sheet(isPresented: viewStore.binding(get: \.isShareFeedbackHalfModalPresented, send: { isPresented in .shareFeedbackHalfModalStateChanged(isPresented) })) {
//          Text("AAA")
//              .frame(height: 300)
//              .background(Color.black)
//              .presentationDetents([.height(300)])
//      }
      .sheet(isPresented: $isPresented) {
          VStack(alignment: .center, spacing: 32) {
              VStack(alignment: .center, spacing: 12) {
                  Text("Email us")
                      .font(.subheadline)
                      .bold()
                  Text("If you need help with the app or want to share feedback, send us an email and we'll get back to you right away.")
                      .font(.caption)
                      .foregroundColor(.godTextSecondaryLight)
                      .lineLimit(3)
              }
              HStack(alignment: .center) {
                  VStack(alignment: .center, spacing: 8) {
                      RoundedRectangle(cornerRadius: 8)
                          .frame(width: 60, height: 60)
                          .background(Color.blue)
                      Text("Mail")
                          .foregroundColor(.godBlack)
                  }
              }
              Button(action: {
                  viewStore.send(.shareFeedbackHalfModalStateChanged(false))
              }, label: {
                  Text("Close")
                      .font(.body)
                      .foregroundColor(.godBlack)
                      .frame(height: 44)
                      .frame(maxWidth: .infinity)
                      .overlay(
                            RoundedRectangle(cornerRadius: 22)
                                .stroke(Color.black, lineWidth: 1)
                      )
              })
          }.presentationDetents([.height(300)])
      }
    }
  }
}

extension ConfirmationDialogState where Action == AboutReducer.Action.ConfirmationDialog {
  static let faq = Self {
    TextState("Get Help")
  } actions: {
    ButtonState(action: .addMySchoolToMyProfile) {
      TextState("Add my schoolto my profile")
    }
    ButtonState(action: .changeMyGrade) {
      TextState("Change my grade")
    }
    ButtonState(action: .changeMyName) {
      TextState("Change my name")
    }
    ButtonState(action: .changeMyGender) {
      TextState("Change my gender")
    }
    ButtonState(action: .deleteMyAccount) {
      TextState("Delete my account")
    }
    ButtonState(action: .purchasesAndGodMode) {
      TextState("Purchases & God Mode")
    }
    ButtonState(action: .reportBug) {
      TextState("Report a bug")
    }
    ButtonState(action: .somethingElse) {
      TextState("Something else")
    }
    ButtonState(role: .cancel) {
      TextState("Cancel")
    }
  } message: {
    TextState("Get Help")
  }
}

struct AboutViewPreviews: PreviewProvider {
  static var previews: some View {
    AboutView(
      store: .init(
        initialState: AboutReducer.State(),
        reducer: { AboutReducer() }
      )
    )
  }
}
