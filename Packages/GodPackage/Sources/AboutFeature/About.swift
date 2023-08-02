import ComposableArchitecture
import Constants
import SwiftUI

public struct AboutReducer: Reducer {
  public init() {}

  public struct State: Equatable {
    @PresentationState var confirmationDialog: ConfirmationDialogState<Action.ConfirmationDialog>?
    public init() {}
  }

  public enum Action: Equatable {
    case howItWorksButtonTapped
    case faqButtonTapped
    case shareFeedbackButtonTapped
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
          Link(destination: Constants.twitterURL) {
            Image("twitter", bundle: .module)
              .resizable()
              .frame(width: 62, height: 62)
          }
          Link(destination: Constants.instagramURL) {
            Image("instagram", bundle: .module)
              .resizable()
              .frame(width: 62, height: 62)
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
        reducer: AboutReducer()
      )
    )
  }
}
