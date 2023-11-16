import AnalyticsClient
import AnimationDisableTransaction
import Build
import ComposableArchitecture
import Constants
import God
import GodClient
import GodModeFeature
import NotificationCenterClient
import RevealFeature
import StoreKit
import StoreKitClient
import Styleguide
import SwiftUI
import InboxStoryFeature
import FeedbackGeneratorClient

@Reducer
public struct InboxDetailLogic {
  public init() {}
  
  @Reducer
  public struct Destination {
    public enum State: Equatable {
      case initialName(InitialNameLogic.State)
      case fullName(FullNameLogic.State)
      case godMode(GodModeLogic.State)
    }

    public enum Action {
      case initialName(InitialNameLogic.Action)
      case fullName(FullNameLogic.Action)
      case godMode(GodModeLogic.Action)
    }

    public var body: some Reducer<State, Action> {
      Scope(state: \.initialName, action: \.initialName, child: InitialNameLogic.init)
      Scope(state: \.fullName, action: \.fullName, child: FullNameLogic.init)
      Scope(state: \.godMode, action: \.godMode, child: GodModeLogic.init)
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

  public enum Action {
    case onTask
    case onAppear
    case closeButtonTapped
    case seeWhoSentItButtonTapped
    case storyButtonTapped(UIImage?)
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
  @Dependency(\.feedbackGenerator) var feedbackGenerator
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
        
      case .closeButtonTapped:
        return .run { _ in
          await dismiss(transaction: .animationDisable)
        }
        
      case .seeWhoSentItButtonTapped where state.isInGodMode:
        guard let initialName = state.activity.initial else { return .none }
        state.destination = .initialName(
          InitialNameLogic.State(
            activityId: state.activity.id,
            initialName: initialName
          )
        )
        return .run { _ in
          await feedbackGenerator.impactOccurred()
        }

      case .seeWhoSentItButtonTapped where !state.isInGodMode:
        guard let id = build.infoDictionary("GOD_MODE_ID", for: String.self)
        else { return .none }
        return .run { send in
          await feedbackGenerator.impactOccurred()
          await send(.productsResponse(TaskResult {
            try await storeClient.products([id])
          }))
        }
        
      case let .storyButtonTapped(.some(image)):
        let backgroundImage = UIImage(resource: ImageResource.storyBackground)
        let pasteboardItems: [String: Any] = [
          "com.instagram.sharedSticker.stickerImage": image,
          "com.instagram.sharedSticker.backgroundImage": backgroundImage
        ]
        UIPasteboard.general.setItems(
          [pasteboardItems],
          options: [.expirationDate: Date().addingTimeInterval(300)]
        )

        return .run { _ in
          await feedbackGenerator.impactOccurred()
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
        
      case .destination(.dismiss):
        state.destination = nil
        return .none
        
      case let .destination(.presented(.initialName(.delegate(.fullName(fullName))))):
        state.destination = nil
        analytics.logEvent("reveal", [
          "question_id": state.activity.question.id,
          "question_text": state.activity.question.text.ja,
          "activity_id": state.activity.id,
          "vote_user_gender": state.activity.voteUser.gender.value ?? "NULL",
        ])
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
    .ifLet(\.$destination, action: \.destination) {
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
  @Environment(\.displayScale) var displayScale
  let store: StoreOf<InboxDetailLogic>

  public init(store: StoreOf<InboxDetailLogic>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      GeometryReader { proxy in
        let receivedSticker = ReceivedSticker(questionText: viewStore.activity.question.text.ja)
          .frame(width: proxy.size.width - 96)
        
        let choiceListSticker = ChoiceListSticker(questionText: viewStore.activity.question.text.ja)
          .frame(width: proxy.size.width - 96)
        
        VStack(spacing: 0) {
          ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 32) {
              receivedSticker
                .compositingGroup()
                .shadow(radius: 12)
              
              choiceListSticker
                .compositingGroup()
                .shadow(radius: 12)
              
            }
            .padding(.top, 52)
            .padding(.bottom, 12)
            .padding(.horizontal, 48)
            .frame(maxHeight: .infinity)
            .scrollTargetLayoutIfPossible()
          }
          .frame(maxWidth: .infinity, maxHeight: .infinity)
          .scrollTargetBehaviorIfPossible()

          VStack(spacing: 12) {
            Button {
              store.send(.seeWhoSentItButtonTapped)
            } label: {
              Label(String(localized: "See who sent it", bundle: .module), systemImage: "lock")
                .font(.system(.headline, design: .rounded, weight: .bold))
                .frame(height: 56)
                .frame(maxWidth: .infinity)
                .foregroundStyle(Color.black)
                .background(
                  LinearGradient(
                    colors: [Color(0xFFE8B423), Color(0xFFF5D068)],
                    startPoint: UnitPoint(x: 0, y: 0.5),
                    endPoint: UnitPoint(x: 1, y: 0.5)
                  )
                )
                .clipShape(Capsule())
            }
            
            Button {
              let renderer = ImageRenderer(
                content: receivedSticker
                  .padding(.vertical, 36)
                  .padding(.horizontal, 4)
              )
              renderer.scale = displayScale
              store.send(.storyButtonTapped(renderer.uiImage))
            } label: {
              Label(String(localized: "Reply", bundle: .module), systemImage: "camera")
                .font(.system(.headline, design: .rounded, weight: .bold))
                .frame(height: 56)
                .frame(maxWidth: .infinity)
                .foregroundStyle(Color.white)
                .background(Color.godBlack)
                .clipShape(Capsule())
            }
          }
          .padding(.horizontal, 16)
          .buttonStyle(HoldDownButtonStyle())
        }
        .overlay(alignment: .topTrailing) {
          Button {
            store.send(.closeButtonTapped)
          } label: {
            Image(systemName: "xmark")
              .font(.system(size: 28, weight: .bold, design: .rounded))
              .foregroundStyle(Color.godTextSecondaryLight)
          }
          .padding(.horizontal, 24)
          .buttonStyle(HoldDownButtonStyle())
        }
      }
      .task { await store.send(.onTask).finish() }
      .onAppear { store.send(.onAppear) }
      .onTapGesture {
        store.send(.closeButtonTapped)
      }
      .fullScreenCover(
        store: store.scope(state: \.$destination, action: InboxDetailLogic.Action.destination),
        state: /InboxDetailLogic.Destination.State.initialName,
        action: InboxDetailLogic.Destination.Action.initialName
      ) { store in
        InitialNameView(store: store)
          .presentationBackground(Color.clear)
      }
      .fullScreenCover(
        store: store.scope(state: \.$destination, action: InboxDetailLogic.Action.destination),
        state: /InboxDetailLogic.Destination.State.fullName,
        action: InboxDetailLogic.Destination.Action.fullName
      ) { store in
        FullNameView(store: store)
          .presentationBackground(Color.clear)
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
