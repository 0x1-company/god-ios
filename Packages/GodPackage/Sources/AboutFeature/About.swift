import Colors
import ComposableArchitecture
import Constants
import HowItWorksFeature
import SwiftUI

public struct AboutReducer: Reducer {
  public init() {}

  public struct State: Equatable {
    @PresentationState var confirmationDialog: ConfirmationDialogState<Action.ConfirmationDialog>?
    @PresentationState var destination: Destination.State?
    public init() {}
  }

  public enum Action: Equatable {
    case howItWorksButtonTapped
    case faqButtonTapped
    case shareFeedbackButtonTapped
    case getHelpButtonTapped
    case safetyCenterButtonTapped
    case confirmationDialog(PresentationAction<ConfirmationDialog>)
    case destination(PresentationAction<Destination.Action>)

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
        state.destination = .howItWorks()
        return .none

      case .faqButtonTapped:
        return .none

      case .shareFeedbackButtonTapped:
        state.destination = .shareFeedback()
        return .none

      case .getHelpButtonTapped:
        state.confirmationDialog = .faq
        return .none

      case .safetyCenterButtonTapped:
        return .none

      case let .confirmationDialog(.presented(action)):
        switch action {
        case .addMySchoolToMyProfile:
          state.destination = .addMySchoolToMyProfile()
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
      case .confirmationDialog(.dismiss):
        state.confirmationDialog = nil
        return .none
      case .confirmationDialog:
        return .none
      case .destination(.presented(.howItWorks(.delegate(.start)))):
        state.destination = nil
        return .none
      case .destination(.dismiss):
        state.destination = nil
        return .none
      case .destination:
        return .none
      }
    }
    .ifLet(\.$destination, action: /Action.destination) {
      Destination()
    }
  }

  public struct Destination: Reducer {
    public enum State: Equatable {
      case shareFeedback(ShareFeedbackReducer.State = .init())
      case addMySchoolToMyProfile(AddMySchoolToMyProfileReducer.State = .init())
      case howItWorks(HowItWorksReducer.State = .init())
    }

    public enum Action: Equatable {
      case shareFeedback(ShareFeedbackReducer.Action)
      case addMySchoolToMyProfile(AddMySchoolToMyProfileReducer.Action)
      case howItWorks(HowItWorksReducer.Action)
    }

    public var body: some Reducer<State, Action> {
      Scope(state: /State.shareFeedback, action: /Action.shareFeedback) {
        ShareFeedbackReducer()
      }
      Scope(state: /State.addMySchoolToMyProfile, action: /Action.addMySchoolToMyProfile) {
        AddMySchoolToMyProfileReducer()
      }
      Scope(state: /State.howItWorks, action: /Action.howItWorks) {
        HowItWorksReducer()
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
      .confirmationDialog(store: store.scope(state: \.$confirmationDialog, action: { .confirmationDialog($0) }))
      .sheet(
        store: store.scope(state: \.$destination, action: { .destination($0) }),
        state: /AboutReducer.Destination.State.shareFeedback,
        action: AboutReducer.Destination.Action.shareFeedback
      ) { store in
        ShareFeedback(store: store)
          .presentationDetents([.height(ShareFeedback.heightForPresentationDetents)])
      }
      .sheet(
        store: store.scope(state: \.$destination, action: { .destination($0) }),
        state: /AboutReducer.Destination.State.addMySchoolToMyProfile,
        action: AboutReducer.Destination.Action.addMySchoolToMyProfile
      ) { store in
        AddMySchoolToMyProfileView(store: store)
          .presentationDetents([.height(ShareFeedback.heightForPresentationDetents)])
      }
      .fullScreenCover(
        store: store.scope(state: \.$destination, action: { .destination($0) }),
        state: /AboutReducer.Destination.State.howItWorks,
        action: AboutReducer.Destination.Action.howItWorks,
        content: HowItWorksView.init(store:)
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
        reducer: { AboutReducer() }
      )
    )
  }
}
