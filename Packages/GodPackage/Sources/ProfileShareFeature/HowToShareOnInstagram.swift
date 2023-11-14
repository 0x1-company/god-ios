import AnalyticsClient
import ComposableArchitecture
import Constants
import God
import GodClient
import ProfileImage
import ProfileStoryFeature
import ShareLinkBuilder
import Styleguide
import SwiftUI
import UIApplicationClient
import UIPasteboardClient

@Reducer
public struct HowToShareOnInstagramLogic {
  public init() {}

  public struct State: Equatable {
    var currentUser: God.CurrentUserQuery.Data.CurrentUser?
    var profileImageData: Data?
    var schoolImageData: Data?

    var allSteps: [Step] = Step.allCases
    var currentStep: Step = .one
    public init() {}
  }

  public enum Action: Equatable {
    case onTask
    case onAppear
    case stepButtonTapped(Step)
    case primaryButtonTapped(profileCardImage: UIImage? = nil)
    case closeButtonTapped
    case currentUserResponse(TaskResult<God.CurrentUserQuery.Data>)
    case profileImageResponse(TaskResult<Data>)
    case schoolImageResponse(TaskResult<Data>)
    case delegate(Delegate)

    public enum Delegate: Equatable {
      case showdStories
    }
  }

  @Dependency(\.dismiss) var dismiss
  @Dependency(\.mainQueue) var mainQueue
  @Dependency(\.openURL) var openURL
  @Dependency(\.godClient) var godClient
  @Dependency(\.analytics) var analytics
  @Dependency(\.pasteboard) var pasteboard
  @Dependency(\.urlSession) var urlSession

  public var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .onTask:
        return .run { send in
          for try await data in godClient.currentUser() {
            await send(.currentUserResponse(.success(data)))
          }
        } catch: { error, send in
          await send(.currentUserResponse(.failure(error)))
        }

      case .onAppear:
        analytics.logScreen(screenName: "HowToShareOnInstagram", of: self)
        return .none

      case let .stepButtonTapped(step):
        state.currentStep = step
        return .none

      case let .primaryButtonTapped(profileCardImage) where state.currentStep == Step.allCases.last:
        analytics.buttonClick(name: .shareOnInstagram)
        guard
          let profileCardImage,
          let imageData = profileCardImage.pngData(),
          let username = state.currentUser?.username
        else { return .none }
        let pasteboardItems: [String: Any] = [
          "com.instagram.sharedSticker.stickerImage": imageData,
          "com.instagram.sharedSticker.backgroundTopColor": "#000000",
          "com.instagram.sharedSticker.backgroundBottomColor": "#000000",
        ]
        pasteboard.setItems(
          [pasteboardItems],
          [.expirationDate: Date().addingTimeInterval(300)]
        )
        let shareLink = ShareLinkBuilder.buildGodLink(
          path: .add,
          username: username,
          source: .instagram,
          medium: .profile
        )
        return .run { send in
          await openURL(Constants.storiesURL)
          try await mainQueue.sleep(for: .seconds(0.5))
          pasteboard.url(shareLink)
          await send(.delegate(.showdStories))
        }

      case .primaryButtonTapped:
        guard let nextStep = Step(rawValue: state.currentStep.rawValue + 1)
        else { return .none }
        state.currentStep = nextStep
        return .none

      case .closeButtonTapped:
        return .run { _ in
          await dismiss()
        }

      case let .currentUserResponse(.success(data)):
        state.currentUser = data.currentUser
        return .run { send in
          await withThrowingTaskGroup(of: Void.self) { group in
            if let imageURL = URL(string: data.currentUser.imageURL) {
              group.addTask {
                do {
                  let (data, _) = try await urlSession.data(from: imageURL)
                  await send(.profileImageResponse(.success(data)))
                } catch {
                  await send(.profileImageResponse(.failure(error)))
                }
              }
            }
            if let imageURL = URL(string: data.currentUser.school?.profileImageURL ?? "") {
              group.addTask {
                do {
                  let (data, _) = try await urlSession.data(from: imageURL)
                  await send(.schoolImageResponse(.success(data)))
                } catch {
                  await send(.schoolImageResponse(.failure(error)))
                }
              }
            }
          }
        }

      case .currentUserResponse(.failure):
        return .run { _ in
          await dismiss()
        }

      case let .profileImageResponse(.success(data)):
        state.profileImageData = data
        return .none

      case let .schoolImageResponse(.success(data)):
        state.schoolImageData = data
        return .none

      default:
        return .none
      }
    }
  }

  public enum Step: Int, CaseIterable {
    case one = 1
    case two = 2
    case three = 3
    case four = 4

    var primaryButtonText: LocalizedStringKey {
      switch self {
      case .one, .two, .three:
        return "Next Step"
      case .four:
        return "Share on Instagram"
      }
    }

    var description: LocalizedStringKey {
      switch self {
      case .one:
        return "Click the button"
      case .two:
        return "click the **LINK** button"
      case .three:
        return "Paste your link"
      case .four:
        return "Frame the link"
      }
    }

    var descriptionImageName: String {
      "step\(rawValue)"
    }
  }
}

public struct HowToShareOnInstagramView: View {
  public static let heightForPresentationDetents: CGFloat = 260
  let store: StoreOf<HowToShareOnInstagramLogic>

  @Environment(\.displayScale) var displayScale

  public init(store: StoreOf<HowToShareOnInstagramLogic>) {
    self.store = store
  }

  @ViewBuilder
  func storyView(
    profileImageData: Data?,
    schoolImageData: Data?,
    user: God.CurrentUserQuery.Data.CurrentUser?
  ) -> some View {
    if let user {
      ProfileStoryView(
        profileImageData: profileImageData,
        firstName: user.firstName,
        displayName: user.displayName.ja,
        username: user.username,
        schoolImageData: schoolImageData,
        schoolName: user.school?.name
      )
    }
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      let instagramStoryView = storyView(
        profileImageData: viewStore.profileImageData,
        schoolImageData: viewStore.schoolImageData,
        user: viewStore.currentUser
      )
      ZStack(alignment: .center) {
        instagramStoryView

        VStack(alignment: .center, spacing: 24) {
          Text("How to add the\nlink to your Story", bundle: .module)
            .font(.system(.title, design: .rounded, weight: .bold))
            .foregroundStyle(Color.godBlack)
            .multilineTextAlignment(.center)

          HStack(alignment: .center, spacing: 12) {
            ForEach(viewStore.allSteps, id: \.rawValue) { step in
              Button {
                store.send(.stepButtonTapped(step))
              } label: {
                Text(String(step.rawValue))
                  .font(.subheadline)
                  .foregroundStyle(viewStore.state.currentStep == step ? Color.godWhite : Color.godBlack)
                  .frame(width: 36, height: 36)
                  .background(viewStore.state.currentStep == step ? Color.godBlack : Color.godWhite)
                  .cornerRadius(18)
                  .overlay(
                    viewStore.state.currentStep == step ? nil :
                      Circle()
                      .stroke(Color.godBlack, lineWidth: 0.5)
                  )
              }
              .buttonStyle(HoldDownButtonStyle())
            }
          }

          Text(viewStore.currentStep.description, bundle: .module)
            .font(.system(.headline, design: .rounded))

          Image(viewStore.currentStep.descriptionImageName, bundle: .module)
            .resizable()
            .frame(maxWidth: .infinity)
            .aspectRatio(contentMode: .fit)
            .clipped()

          Button {
            let renderer = ImageRenderer(content: instagramStoryView)
            renderer.scale = displayScale
            store.send(.primaryButtonTapped(profileCardImage: renderer.uiImage))
          } label: {
            Text(viewStore.currentStep.primaryButtonText, bundle: .module)
              .font(.system(.body, design: .rounded, weight: .bold))
              .foregroundStyle(Color.godWhite)
              .frame(maxWidth: .infinity)
              .frame(height: 52)
              .background(Color.godService)
              .cornerRadius(26)
          }
          .buttonStyle(HoldDownButtonStyle())
        }
        .padding(20)
        .background(Color.godWhite)
        .cornerRadius(24)
      }
      .task { await store.send(.onTask).finish() }
      .onAppear { store.send(.onAppear) }
    }
  }
}

#Preview {
  HowToShareOnInstagramView(
    store: .init(
      initialState: HowToShareOnInstagramLogic.State(),
      reducer: { HowToShareOnInstagramLogic() }
    )
  )
}
