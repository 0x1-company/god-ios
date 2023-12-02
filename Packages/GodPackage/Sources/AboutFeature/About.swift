import AnalyticsClient
import Build
import ComposableArchitecture
import Constants
import DeleteAccountFeature
import EmailFeature
import HowItWorksFeature
import Styleguide
import SwiftUI

@Reducer
public struct AboutLogic {
  public init() {}

  @Reducer
  public struct Destination {
    public enum State: Equatable {
      case howItWorks(HowItWorksLogic.State = .init())
      case emailSheet(EmailSheetLogic.State)
      case deleteAccount(DeleteAccountLogic.State = .init())
    }

    public enum Action {
      case howItWorks(HowItWorksLogic.Action)
      case emailSheet(EmailSheetLogic.Action)
      case deleteAccount(DeleteAccountLogic.Action)
    }

    public var body: some Reducer<State, Action> {
      Scope(state: \.howItWorks, action: \.howItWorks, child: HowItWorksLogic.init)
      Scope(state: \.emailSheet, action: \.emailSheet, child: EmailSheetLogic.init)
      Scope(state: \.deleteAccount, action: \.deleteAccount, child: DeleteAccountLogic.init)
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

  public enum Action {
    case onTask
    case onAppear
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
  @Dependency(\.analytics) var analytics

  public var body: some Reducer<State, Action> {
    Reduce<State, Action> { state, action in
      switch action {
      case .onTask:
        return .none

      case .onAppear:
        analytics.logScreen(screenName: "About", of: self)
        return .none

      case .howItWorksButtonTapped:
        state.destination = .howItWorks()
        analytics.buttonClick(name: .howItWorks)
        return .none

      case .faqButtonTapped:
        analytics.buttonClick(name: .faq)
        return .run { _ in
          await openURL(Constants.faqURL)
        }

      case .shareFeedbackButtonTapped:
        analytics.buttonClick(name: .shareFeedback)
        state.destination = .emailSheet(
          EmailSheetLogic.State(title: String(localized: "Email us", bundle: .module))
        )
        return .none

      case .getHelpButtonTapped:
        analytics.buttonClick(name: .getHelp)
        state.confirmationDialog = .getHelp
        return .none

      case .safetyCenterButtonTapped:
        analytics.buttonClick(name: .safetyCenter)
        return .run { _ in
          await openURL(Constants.safetyCenterURL)
        }

      case let .confirmationDialog(.presented(action)):
        switch action {
        case .addMySchoolToMyProfile:
          analytics.buttonClick("add_my_school_to_my_profile")
          state.destination = .emailSheet(EmailSheetLogic.State(title: String(localized: "Add my school to my profile", bundle: .module)))
        case .changeMyGrade:
          analytics.buttonClick("change_my_grade")
          state.destination = .emailSheet(EmailSheetLogic.State(title: String(localized: "Change my grade", bundle: .module)))
        case .changeMyGender:
          analytics.buttonClick("change_my_gender")
          state.destination = .emailSheet(EmailSheetLogic.State(title: String(localized: "Change my gender", bundle: .module)))
        case .changeMyName:
          analytics.buttonClick("change_my_name")
          state.destination = .emailSheet(EmailSheetLogic.State(title: String(localized: "Change my name", bundle: .module)))
        case .deleteMyAccount:
          analytics.buttonClick("delete_my_account")
          state.destination = .deleteAccount()
        case .purchasesAndGodMode:
          analytics.buttonClick("purchases_and_god_mode")
          state.destination = .emailSheet(EmailSheetLogic.State(title: String(localized: "Purchases & God Mode", bundle: .module)))
        case .reportBug:
          analytics.buttonClick("report_bug")
          state.destination = .emailSheet(EmailSheetLogic.State(title: String(localized: "Report a bug", bundle: .module)))
        case .somethingElse:
          analytics.buttonClick("something_else")
          state.destination = .emailSheet(EmailSheetLogic.State(title: String(localized: "Something else", bundle: .module)))
        }
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
    .ifLet(\.$destination, action: \.destination) {
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
            store.send(.howItWorksButtonTapped)
          }
          IconButton("FAQ", image: .clipboard) {
            store.send(.faqButtonTapped)
          }
          IconButton("Share Feedback", image: .megaphone) {
            store.send(.shareFeedbackButtonTapped)
          }
          IconButton("Get Help", image: .rescueWorkersHelmet) {
            store.send(.getHelpButtonTapped)
          }
          IconButton("Safety Center", image: .shield) {
            store.send(.safetyCenterButtonTapped)
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
        .foregroundStyle(.secondary)
        .tint(.secondary)
      }
      .task { await store.send(.onTask).finish() }
      .onAppear { store.send(.onAppear) }
      .confirmationDialog(
        store: store.scope(
          state: \.$confirmationDialog,
          action: \.confirmationDialog
        )
      )
      .fullScreenCover(
        store: store.scope(
          state: \.$destination.howItWorks,
          action: \.destination.howItWorks
        ),
        content: HowItWorksView.init(store:)
      )
      .sheet(
        store: store.scope(
          state: \.$destination.emailSheet,
          action: \.destination.emailSheet
        )
      ) { store in
        EmailSheetView(store: store)
          .presentationBackground(Color.clear)
      }
      .sheet(
        store: store.scope(
          state: \.$destination.deleteAccount,
          action: \.destination.deleteAccount
        )
      ) { store in
        NavigationStack {
          DeleteAccountView(store: store)
        }
      }
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
