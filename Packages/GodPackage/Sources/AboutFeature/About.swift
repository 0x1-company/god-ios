import Build
import ComposableArchitecture
import Constants
import HowItWorksFeature
import Styleguide
import EmailFeature
import SwiftUI

public struct AboutLogic: Reducer {
  public init() {}
  public struct Destination: Reducer {
    public enum State: Equatable {
      case howItWorks(HowItWorksLogic.State = .init())
      case emailSheet(EmailSheetLogic.State)
    }

    public enum Action: Equatable {
      case howItWorks(HowItWorksLogic.Action)
      case emailSheet(EmailSheetLogic.Action)
    }

    public var body: some Reducer<State, Action> {
      Scope(state: /State.howItWorks, action: /Action.howItWorks, child: HowItWorksLogic.init)
      Scope(state: /State.emailSheet, action: /Action.emailSheet, child: EmailSheetLogic.init)
    }
  }

  public struct State: Equatable {
    @PresentationState var confirmationDialog: ConfirmationDialogState<Action.ConfirmationDialog>?
    @PresentationState var destination: Destination.State?
    let appVersion: String
    public init() {
      @Dependency(\.build) var build
      let bundleVersion = build.bundleVersion()
      let bundleShortVersion = build.bundleShortVersion()
      appVersion = "\(bundleShortVersion) (\(bundleVersion))"
    }
  }

  public enum Action: Equatable {
    case onTask
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
      case .onTask:
        return .none
      case .howItWorksButtonTapped:
        state.destination = .howItWorks()
        return .none

      case .faqButtonTapped:
        return .run { _ in
          await openURL(Constants.faqURL)
        }
      case .shareFeedbackButtonTapped:
        state.destination = .emailSheet(
          EmailSheetLogic.State(title: String(localized: "Email us", bundle: .module))
        )
        return .none

      case .getHelpButtonTapped:
        state.confirmationDialog = .getHelp
        return .none

      case .safetyCenterButtonTapped:
        return .run { _ in
          await openURL(Constants.safetyCenterURL)
        }

      case let .confirmationDialog(.presented(action)):
        let emailState: EmailSheetLogic.State
        switch action {
        case .addMySchoolToMyProfile:
          emailState = .init(
            title: String(localized: "Add my school to my profile", bundle: .module)
          )
        case .changeMyGrade:
          emailState = .init(
            title: String(localized: "Change my grade", bundle: .module)
          )
        case .changeMyGender:
          emailState = .init(
            title: String(localized: "Change my gender", bundle: .module)
          )
        case .changeMyName:
          emailState = .init(
            title: String(localized: "Change my name", bundle: .module)
          )
        case .deleteMyAccount:
          emailState = .init(
            title: String(localized: "Delete my account", bundle: .module)
          )
        case .purchasesAndGodMode:
          emailState = .init(
            title: String(localized: "Purchases & God Mode", bundle: .module)
          )
        case .reportBug:
          emailState = .init(
            title: String(localized: "Report a bug", bundle: .module)
          )
        case .somethingElse:
          emailState = .init(
            title: String(localized: "Something else", bundle: .module)
          )
        }
        state.destination = .emailSheet(emailState)
        return .none
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
        .buttonStyle(HoldDownButtonStyle())

        VStack(spacing: 8) {
          Image(ImageResource.god)
            .resizable()
            .scaledToFit()
            .frame(width: 94)

          Text("[Terms](https://docs.godapp.jp/terms-of-use) / [Privacy](https://docs.godapp.jp/privacy-policy)", bundle: .module)
            .font(.system(.footnote, design: .rounded))

          Text(viewStore.appVersion)
            .font(.system(.footnote, design: .rounded))
        }
        .foregroundColor(.secondary)
        .tint(.secondary)
      }
      .task { await store.send(.onTask).finish() }
      .confirmationDialog(store: store.scope(state: \.$confirmationDialog, action: { .confirmationDialog($0) }))
      .sheet(
        store: store.scope(state: \.$destination, action: { .destination($0) }),
        state: /AboutLogic.Destination.State.emailSheet,
        action: AboutLogic.Destination.Action.emailSheet
      ) { store in
        EmailSheetView(store: store)
          .presentationBackground(Color.clear)
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
    TextState("Get Help", bundle: .module)
  } actions: {
    ButtonState(action: .addMySchoolToMyProfile) {
      TextState("Add my school to my profile", bundle: .module)
    }
    ButtonState(action: .changeMyGrade) {
      TextState("Change my grade", bundle: .module)
    }
    ButtonState(action: .changeMyName) {
      TextState("Change my name", bundle: .module)
    }
    ButtonState(action: .changeMyGender) {
      TextState("Change my gender", bundle: .module)
    }
    ButtonState(action: .deleteMyAccount) {
      TextState("Delete my account", bundle: .module)
    }
    ButtonState(action: .purchasesAndGodMode) {
      TextState("Purchases & God Mode", bundle: .module)
    }
    ButtonState(action: .reportBug) {
      TextState("Report a bug", bundle: .module)
    }
    ButtonState(action: .somethingElse) {
      TextState("Something else", bundle: .module)
    }
    ButtonState(role: .cancel) {
      TextState("Cancel", bundle: .module)
    }
  } message: {
    TextState("Get Help", bundle: .module)
  }
}

#Preview {
  AboutView(
    store: .init(
      initialState: AboutLogic.State(),
      reducer: { AboutLogic() }
    )
  )
}
