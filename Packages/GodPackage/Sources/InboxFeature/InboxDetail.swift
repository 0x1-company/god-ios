import ButtonStyles
import Colors
import ComposableArchitecture
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
    case shareOnInstagramButtonTapped(UIImage)
    case destination(PresentationAction<Destination.Action>)
  }

  @Dependency(\.dismiss) var dismiss
  @Dependency(\.photos) var photos
  @Dependency(\.notificationCenter) var notificationCenter
  @Dependency(\.openURL) var openURL

  public var body: some Reducer<State, Action> {
    Reduce<State, Action> { state, action in
      switch action {
      case .onTask:
        return .none

      case .seeWhoSentItButtonTapped:
        state.destination = .reveal(
          .init(activityId: state.activity.id)
        )
        return .none

      case .closeButtonTapped:
        return .run { _ in
          await dismiss()
        }

      case .destination(.dismiss):
        state.destination = nil
        return .none

      case let .shareOnInstagramButtonTapped(stickerImage):
        if let storiesUrl = URL(string: "instagram-stories://share?source_application=1049646559806019") {
          if UIApplication.shared.canOpenURL(storiesUrl) {
            guard let imageData = stickerImage.pngData() else {
              assertionFailure()
              return .none
            }
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
              await openURL(storiesUrl)
            }
          } else {
            print("Sorry the application is not installed")
            assertionFailure()
            return .none
          }
        }
        return .none

      case let .destination(.presented(.reveal(.delegate(.fullName(fullName))))):
        state.destination = .fullName(
          .init(fulName: fullName)
        )
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
  
  func backgroundColor(gender: God.Gender?) -> Color {
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
      let shareOnInstagramStoryView = shareOnInstagramStoryView(question: viewStore.activity.question.text.ja)
      ZStack {
        // instagramへのシェア用のView
        shareOnInstagramStoryView

        Color.black

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

            VStack(spacing: 20) {
              Text(viewStore.activity.question.text.ja)
                .bold()
                .font(.title2)
                .foregroundColor(.white)

              Text(verbatim: "godapp.jp")
                .bold()
            }
            Spacer()
          }
          .frame(maxWidth: .infinity, maxHeight: .infinity)
          .background(backgroundColor(gender: viewStore.activity.voteUser.gender.value))
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
                .presentationDetents([.fraction(0.4)])
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

  @ViewBuilder
  private func shareOnInstagramStoryView(question: String) -> some View {
    let mockChoices = ["Nozomi Isshiki", "Anette Escobedo", "Satoya Hatanaka", "Ava Griego"]
    let mockSelectedUser = "Nozomi Isshiki"
    VStack(alignment: .center, spacing: 12) {
      HStack(alignment: .center, spacing: 8) {
        Image("boy", bundle: .module)
          .resizable()
          .frame(width: 36, height: 36)

        Text("N年生の男子から")
          .font(.callout)
          .bold()
          .foregroundColor(.white)
          .lineLimit(2)
          .multilineTextAlignment(.leading)

        Spacer()

        Text("LBHS")
          .font(.body)
          .bold()
          .foregroundColor(.godWhite)
          .frame(height: 32)
          .padding(.horizontal, 8)
          .background(Color.godGray)
          .cornerRadius(20)
      }
      VStack(alignment: .center, spacing: 0) {
        Text(question)
          .font(.callout)
          .bold()
          .foregroundColor(.godWhite)
          .lineLimit(2)
          .frame(height: 80, alignment: .center)

        LazyVGrid(
          columns: Array(repeating: GridItem(spacing: 16), count: 2),
          spacing: 16
        ) {
          ForEach(mockChoices, id: \.self) { choice in
            let isSelectedUser = choice == mockSelectedUser
            Text(verbatim: choice)
              .font(.callout)
              .bold()
              .lineLimit(2)
              .multilineTextAlignment(.leading)
              .padding(.horizontal, 16)
              .frame(height: 64)
              .frame(maxWidth: .infinity, alignment: .leading)
              .foregroundStyle(Color.godPurple)
              .background(
                Color.godWhite
              )
              .cornerRadius(8)
              .opacity(isSelectedUser ? 1 : 0.6)
              .overlay(
                isSelectedUser ?
                  Image("finger-icon", bundle: .module)
                  .resizable()
                  .frame(width: 48, height: 48)
                  .rotationEffect(.degrees(-30))
                  .shadow(color: .godPurple, radius: 8)
                  .offset(x: 20, y: -20) : nil,
                alignment: .topTrailing
              )
          }
        }

        Image("god-icon-white", bundle: .module)
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(height: 24)
          .foregroundStyle(Color.godWhite)
          .padding(.top, 10)
          .padding(.bottom, 4)

        Text(verbatim: "godapp.jp")
          .font(.callout)
          .bold()
          .foregroundColor(.godWhite)
      }
      .padding(.horizontal, 16)
      .padding(.bottom, 16)
      .background(Color.godPurple)
      .cornerRadius(8)
    }
    .frame(maxWidth: .infinity)
    .padding(.horizontal, 44)
    .background(Color.clear)
  }
}
