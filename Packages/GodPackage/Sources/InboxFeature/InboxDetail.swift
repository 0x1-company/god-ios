import AnalyticsClient
import Build
import ComposableArchitecture
import Constants
import God
import GodClient
import GodModeFeature
import NotificationCenterClient
import RevealFeature
import ShareScreenshotFeature
import Styleguide
import SwiftUI
import StoreKitClient
import StoreKit

public struct InboxDetailLogic: Reducer {
  public init() {}
  public struct Destination: Reducer {
    public enum State: Equatable {
      case reveal(RevealLogic.State)
      case fullName(FullNameLogic.State)
      case godMode(GodModeLogic.State)
    }
    public enum Action: Equatable {
      case reveal(RevealLogic.Action)
      case fullName(FullNameLogic.Action)
      case godMode(GodModeLogic.Action)
    }
    public var body: some Reducer<State, Action> {
      Scope(state: /State.reveal, action: /Action.reveal, child: RevealLogic.init)
      Scope(state: /State.fullName, action: /Action.fullName, child: FullNameLogic.init)
      Scope(state: /State.godMode, action: /Action.godMode, child: GodModeLogic.init)
    }
  }

  public struct State: Equatable {
    let activity: God.InboxFragment

    var isInGodMode: Bool
    @PresentationState var destination: Destination.State?

    public init(activity: God.InboxFragment, isInGodMode: Bool) {
      self.activity = activity
      self.isInGodMode = isInGodMode
    }
  }

  public enum Action: Equatable {
    case onTask
    case onAppear
    case seeWhoSentItButtonTapped
    case closeButtonTapped
    case shareOnInstagramButtonTapped(UIImage?)
    case showFullName(String)
    case productsResponse(TaskResult<[Product]>)
    case activeSubscriptionResponse(TaskResult<God.ActiveSubscriptionQuery.Data>)
    case destination(PresentationAction<Destination.Action>)
  }

  @Dependency(\.build) var build
  @Dependency(\.dismiss) var dismiss
  @Dependency(\.openURL) var openURL
  @Dependency(\.store) var storeClient
  @Dependency(\.mainQueue) var mainQueue
  @Dependency(\.analytics) var analytics
  @Dependency(\.godClient) var godClient
  @Dependency(\.notificationCenter) var notificationCenter
  
  enum Cancel {
    case activeSubscription
  }

  public var body: some Reducer<State, Action> {
    Reduce<State, Action> { state, action in
      switch action {
      case .onTask:
        return .run { send in
          await withTaskGroup(of: Void.self) { group in
            group.addTask {
              await activeSubscriptionRequest(send: send)
            }
          }
        }

      case .onAppear:
        analytics.logScreen(screenName: "InboxDetail", of: self)
        return .none
        
      case .seeWhoSentItButtonTapped where state.isInGodMode:
        state.destination = .reveal(.init(activity: state.activity))
        return .none
        
      case .seeWhoSentItButtonTapped where !state.isInGodMode:
        guard let id = build.infoDictionary("GOD_MODE_ID", for: String.self)
        else { return .none }
        return .run { send in
          await send(.productsResponse(TaskResult {
            try await storeClient.products([id])
          }))
        }

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
        
      case let .productsResponse(.success(products)):
        guard
          let id = build.infoDictionary("GOD_MODE_ID", for: String.self),
          let product = products.first(where: { $0.id == id })
        else { return .none }
        state.destination = .godMode(
          GodModeLogic.State(product: product)
        )
        return .none
        
      case let .activeSubscriptionResponse(.success(data)):
        state.isInGodMode = data.activeSubscription != nil
        return .none

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
  
  func activeSubscriptionRequest(send: Send<Action>) async {
    await withTaskCancellation(id: Cancel.activeSubscription, cancelInFlight: true) {
      do {
        for try await data in godClient.activeSubscription() {
          await send(.activeSubscriptionResponse(.success(data)))
        }
      } catch {
        await send(.activeSubscriptionResponse(.failure(error)))
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

              Group {
                if let grade = viewStore.activity.voteUser.grade {
                  Text("From \(genderText(gender: viewStore.activity.voteUser.gender.value)) in \(grade)", bundle: .module)
                } else {
                  Text("From a \(genderText(gender: viewStore.activity.voteUser.gender.value))", bundle: .module)
                }
              }
              .font(.system(.body, design: .rounded, weight: .bold))
            }

            VStack(spacing: 32) {
              Text(viewStore.activity.question.text.ja)
                .foregroundColor(.white)
                .font(.system(.title2, design: .rounded, weight: .bold))

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
            store.send(.closeButtonTapped)
          }

          Button {
            store.send(.seeWhoSentItButtonTapped)
          } label: {
            Label {
              Text("See who sent it", bundle: .module)
            } icon: {
              Image(systemName: "lock.fill")
            }
          }
          .buttonStyle(SeeWhoSentItButtonStyle())
        }
      }
      .task { await viewStore.send(.onTask).finish() }
      .onAppear { store.send(.onAppear) }
      .sheet(
        store: store.scope(state: \.$destination, action: InboxDetailLogic.Action.destination),
        state: /InboxDetailLogic.Destination.State.reveal,
        action: InboxDetailLogic.Destination.Action.reveal
      ) { store in
        RevealView(store: store)
          .presentationDetents([.fraction(0.4)])
      }
      .sheet(
        store: store.scope(state: \.$destination, action: InboxDetailLogic.Action.destination),
        state: /InboxDetailLogic.Destination.State.fullName,
        action: InboxDetailLogic.Destination.Action.fullName
      ) { store in
        FullNameView(store: store)
          .presentationDetents([.height(180)])
      }
      .fullScreenCover(
        store: store.scope(state: \.$destination, action: InboxDetailLogic.Action.destination),
        state: /InboxDetailLogic.Destination.State.godMode,
        action: InboxDetailLogic.Destination.Action.godMode,
        content: GodModeView.init(store:)
      )
    }
  }
}
