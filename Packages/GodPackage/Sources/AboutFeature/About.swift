import Colors
import ComposableArchitecture
import Constants
import HowItWorksFeature
import SwiftUI

public struct AboutLogic: Reducer {
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

  @Dependency(\.openURL) var openURL

  public var body: some Reducer<State, Action> {
    Reduce<State, Action> { state, action in
      switch action {
      case .howItWorksButtonTapped:
        state.destination = .howItWorks()
        return .none

      case .faqButtonTapped:
        return .run { _ in
          await openURL(Constants.faqURL)
        }
      case .shareFeedbackButtonTapped:
        state.destination = .shareFeedback()
        return .none

      case .getHelpButtonTapped:
        state.confirmationDialog = .getHelp
        return .none

      case .safetyCenterButtonTapped:
        return .run { _ in
          await openURL(Constants.safetyCenterURL)
        }

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
      case shareFeedback(ShareFeedbackLogic.State = .init())
      case addMySchoolToMyProfile(AddMySchoolToMyProfileLogic.State = .init())
      case howItWorks(HowItWorksLogic.State = .init())
    }

    public enum Action: Equatable {
      case shareFeedback(ShareFeedbackLogic.Action)
      case addMySchoolToMyProfile(AddMySchoolToMyProfileLogic.Action)
      case howItWorks(HowItWorksLogic.Action)
    }

    public var body: some Reducer<State, Action> {
      Scope(state: /State.shareFeedback, action: /Action.shareFeedback) {
        ShareFeedbackLogic()
      }
      Scope(state: /State.addMySchoolToMyProfile, action: /Action.addMySchoolToMyProfile) {
        AddMySchoolToMyProfileLogic()
      }
      Scope(state: /State.howItWorks, action: /Action.howItWorks) {
        HowItWorksLogic()
      }
    }
  }
}

public struct AboutView: View {
  let store: StoreOf<AboutLogic>

  public init(store: StoreOf<AboutLogic>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      VStack(spacing: 32) {
        VStack(alignment: .center, spacing: 24) {
          IconButton("How It Works", image: .womanTeacher) {
            viewStore.send(.howItWorksButtonTapped)
          }
          IconButton("FAQ", image: .clipboard) {
            viewStore.send(.faqButtonTapped)
          }
          IconButton("Share Feedback", image: .megaphone) {
            viewStore.send(.shareFeedbackButtonTapped)
          }
          IconButton("Get Help", image: .rescueWorkersHelmet) {
            viewStore.send(.getHelpButtonTapped)
          }
          IconButton("Safety Center", image: .shield) {
            viewStore.send(.safetyCenterButtonTapped)
          }
        }
        .padding(.top, 24)
        .padding(.horizontal, 32)

        Spacer()

        HStack(spacing: 16) {
          Link(destination: Constants.instagramURL) {
            Image(.instagram)
              .resizable()
              .frame(width: 62, height: 62)
          }
          Link(destination: Constants.xURL) {
            Image(.x)
              .resizable()
              .frame(width: 62, height: 62)
              .clipShape(Circle())
          }
          Link(destination: Constants.tiktokURL) {
            Image(.tiktok)
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
        state: /AboutLogic.Destination.State.shareFeedback,
        action: AboutLogic.Destination.Action.shareFeedback
      ) { store in
        ShareFeedback(store: store)
          .presentationDetents([.height(ShareFeedback.heightForPresentationDetents)])
      }
      .sheet(
        store: store.scope(state: \.$destination, action: { .destination($0) }),
        state: /AboutLogic.Destination.State.addMySchoolToMyProfile,
        action: AboutLogic.Destination.Action.addMySchoolToMyProfile
      ) { store in
        AddMySchoolToMyProfileView(store: store)
          .presentationDetents([.height(ShareFeedback.heightForPresentationDetents)])
      }
      .fullScreenCover(
        store: store.scope(state: \.$destination, action: { .destination($0) }),
        state: /AboutLogic.Destination.State.howItWorks,
        action: AboutLogic.Destination.Action.howItWorks,
        content: HowItWorksView.init(store:)
      )
    }
  }
}

extension ConfirmationDialogState where Action == AboutLogic.Action.ConfirmationDialog {
  static let getHelp = Self {
    TextState("Get Help")
  } actions: {
    ButtonState(action: .addMySchoolToMyProfile) {
      TextState("Add my school to my profile")
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
        initialState: AboutLogic.State(),
        reducer: { AboutLogic() }
      )
    )
  }
}
