import Styleguide
import Styleguide
import ComposableArchitecture
import Constants
import God
import GodClient
import NotificationCenterClient
import Photos
import PhotosClient
import RevealFeature
import ShareScreenshotFeature
import SwiftUI

public struct InboxDetailLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    let activity: God.InboxFragment

    @PresentationState var destination: Destination.State?
    let isInGodMode: Bool

    public init(activity: God.InboxFragment, isInGodMode: Bool) {
      self.activity = activity
      self.isInGodMode = isInGodMode
    }
  }

  public enum Action: Equatable {
    case onTask
    case seeWhoSentItButtonTapped
    case closeButtonTapped
    case shareOnInstagramButtonTapped(UIImage?)
    case showFullName(String)
    case destination(PresentationAction<Destination.Action>)
  }

  @Dependency(\.dismiss) var dismiss
  @Dependency(\.photos) var photos
  @Dependency(\.notificationCenter) var notificationCenter
  @Dependency(\.openURL) var openURL
  @Dependency(\.mainQueue) var mainQueue

  public var body: some Reducer<State, Action> {
    Reduce<State, Action> { state, action in
      switch action {
      case .onTask:
        return .none

      case .seeWhoSentItButtonTapped:
        state.destination = .reveal(.init(activity: state.activity))
        return .none

      case .closeButtonTapped:
        return .run { _ in
          await dismiss()
        }

      case .destination(.dismiss):
        state.destination = nil
        return .none

      case let .shareOnInstagramButtonTapped(.some(stickerImage)):
        guard let imageData = stickerImage.pngData() else { return .none }
        let pasteboardItems: [String: Any] = [
          "com.instagram.sharedSticker.stickerImage": imageData,
          "com.instagram.sharedSticker.backgroundTopColor": "#000000",
          "com.instagram.sharedSticker.backgroundBottomColor": "#000000",
        ]
        UIPasteboard.general.setItems(
          [pasteboardItems],
          options: [.expirationDate: Date().addingTimeInterval(300)]
        )

        return .run { _ in
          await openURL(Constants.storiesURL)
        }

      case let .destination(.presented(.reveal(.delegate(.fullName(fullName))))):
        state.destination = nil
        return .run { send in
          try await mainQueue.sleep(for: .seconds(1))
          await send(.showFullName(fullName))
        }

      case let .showFullName(fullName):
        state.destination = .fullName(
          .init(fulName: fullName)
        )
        return .none

      default:
        return .none
      }
    }
    .ifLet(\.$destination, action: /Action.destination) {
      Destination()
    }
  }

  public struct Destination: Reducer {
    public enum State: Equatable {
      case reveal(RevealLogic.State)
      case fullName(FullNameLogic.State)
      case shareScreenshot(ShareScreenshotLogic.State)
    }

    public enum Action: Equatable {
      case reveal(RevealLogic.Action)
      case fullName(FullNameLogic.Action)
      case shareScreenshot(ShareScreenshotLogic.Action)
    }

    public var body: some Reducer<State, Action> {
      Scope(state: /State.reveal, action: /Action.reveal) {
        RevealLogic()
      }
      Scope(state: /State.fullName, action: /Action.fullName) {
        FullNameLogic()
      }
      Scope(state: /State.shareScreenshot, action: /Action.shareScreenshot) {
        ShareScreenshotLogic()
      }
    }
  }
}

public struct InboxDetailView: View {
  let store: StoreOf<InboxDetailLogic>
  @Environment(\.displayScale) var displayScale

  public init(store: StoreOf<InboxDetailLogic>) {
    self.store = store
  }

  func genderColor(gender: God.Gender?) -> Color {
    switch gender {
    case .male:
      return Color.godBlue
    case .female:
      return Color.godPink
    default:
      return Color.godPurple
    }
  }

  func genderIcon(gender: God.Gender?) -> ImageResource {
    switch gender {
    case .male:
      return ImageResource.boy
    case .female:
      return ImageResource.girl
    default:
      return ImageResource.other
    }
  }

  func genderText(gender: God.Gender?) -> String {
    switch gender {
    case .male:
      return String(localized: "boy", bundle: .module)
    case .female:
      return String(localized: "girl", bundle: .module)
    default:
      return String(localized: "someone", bundle: .module)
    }
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      let instagramStoryView = InstagramStoryView(
        question: viewStore.activity.question.text.ja,
        color: genderColor(gender: viewStore.activity.voteUser.gender.value),
        icon: genderIcon(gender: viewStore.activity.voteUser.gender.value),
        gender: genderText(gender: viewStore.activity.voteUser.gender.value),
        grade: viewStore.activity.voteUser.grade,
        schoolName: nil,
        choices: viewStore.activity.choices
      )
      ZStack {
        instagramStoryView

        VStack {
          VStack(spacing: 50) {
            Spacer()

            VStack(spacing: 20) {
              Image(genderIcon(gender: viewStore.activity.voteUser.gender.value))
                .resizable()
                .frame(width: 80, height: 80)

              if let grade = viewStore.activity.voteUser.grade {
                Text("From \(genderText(gender: viewStore.activity.voteUser.gender.value))\nin \(grade)", bundle: .module)
              } else {
                Text("From a \(genderText(gender: viewStore.activity.voteUser.gender.value))", bundle: .module)
              }
            }

            VStack(spacing: 32) {
              Text(viewStore.activity.question.text.ja)
                .bold()
                .font(.title2)
                .foregroundColor(.white)

              VStack(spacing: 20) {
                ChoiceGrid(
                  color: genderColor(gender: viewStore.activity.voteUser.gender.value),
                  choices: viewStore.activity.choices
                )

                Text(verbatim: "godapp.jp")
                  .bold()
                  .font(.title3)
              }
            }
            .padding(.horizontal, 36)

            Spacer()

            StoriesButton {
              let renderer = ImageRenderer(content: instagramStoryView)
              renderer.scale = displayScale
              store.send(.shareOnInstagramButtonTapped(renderer.uiImage))
            }
            .padding(.all, 20)
          }
          .frame(maxWidth: .infinity, maxHeight: .infinity)
          .background(genderColor(gender: viewStore.activity.voteUser.gender.value))
          .foregroundColor(.godWhite)
          .multilineTextAlignment(.center)
          .onTapGesture {
            viewStore.send(.closeButtonTapped)
          }

          if viewStore.isInGodMode {
            Button {
              viewStore.send(.seeWhoSentItButtonTapped)
            } label: {
              Label("See who sent it", systemImage: "lock.fill")
                .frame(height: 50)
                .frame(maxWidth: .infinity)
                .bold()
                .foregroundColor(.white)
                .background(Color.godGray)
                .clipShape(Capsule())
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
            .buttonStyle(HoldDownButtonStyle())
          }
        }
      }
      .task { await viewStore.send(.onTask).finish() }
      .sheet(
        store: store.scope(state: \.$destination, action: { .destination($0) })
      ) { initialState in
        SwitchStore(initialState) {
          switch $0 {
          case .reveal:
            CaseLet(
              /InboxDetailLogic.Destination.State.reveal,
              action: InboxDetailLogic.Destination.Action.reveal
            ) { store in
              RevealView(store: store)
                .presentationDetents([.fraction(0.4)])
            }
          case .fullName:
            CaseLet(
              /InboxDetailLogic.Destination.State.fullName,
              action: InboxDetailLogic.Destination.Action.fullName
            ) { store in
              FullNameView(store: store)
                .presentationDetents([.height(180)])
            }
          case .shareScreenshot:
            CaseLet(
              /InboxDetailLogic.Destination.State.shareScreenshot,
              action: InboxDetailLogic.Destination.Action.shareScreenshot
            ) { store in
              ShareScreenshotView(store: store)
                .presentationDetents([.fraction(0.3)])
                .presentationDragIndicator(.visible)
            }
          }
        }
      }
    }
  }
}
