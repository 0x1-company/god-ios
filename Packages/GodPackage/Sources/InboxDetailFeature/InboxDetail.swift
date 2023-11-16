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
    @PresentationState var destination: Destination.State?
    public init() {}
  }

  public enum Action {
    case onTask
    case onAppear
    case closeButtonTapped
    case seeWhoSentItButtonTapped
    case storyButtonTapped(UIImage?)
    case destination(PresentationAction<Destination.Action>)
  }

  @Dependency(\.openURL) var openURL
  @Dependency(\.dismiss) var dismiss
  @Dependency(\.analytics) var analytics

  public var body: some Reducer<State, Action> {
    Reduce<State, Action> { _, action in
      switch action {
      case .onTask:
        return .none

      case .onAppear:
        analytics.logScreen(screenName: "InboxDetail", of: self)
        return .none
        
      case .closeButtonTapped:
        return .run { _ in
          await dismiss(transaction: .animationDisable)
        }
        
      case let .storyButtonTapped(.some(image)):
        guard let imageData = image.pngData() else { return .none }
        let pasteboardItems: [String: Any] = [
          "com.instagram.sharedSticker.stickerImage": imageData,
        ]
        UIPasteboard.general.setItems(
          [pasteboardItems],
          options: [.expirationDate: Date().addingTimeInterval(300)]
        )

        return .run { _ in
          await openURL(Constants.storiesURL)
        }
        
      default:
        return .none
      }
    }
    .ifLet(\.$destination, action: \.destination) {
      Destination()
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
      let receiveStory = ReciveStoryView()
      let choiceListStory = ChoiceListStoryView()
      ZStack {
        choiceListStory
        receiveStory

        VStack(spacing: 0) {
          GeometryReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
              HStack(spacing: 32) {
                ReciveSticker(questionText: "Your ideal study buddy")
                  .frame(width: proxy.size.width - 96)
                
                ChoiceListSticker(questionText: "Your ideal study buddy")
                  .frame(width: proxy.size.width - 96)
                
              }
              .padding(.vertical, 32)
              .padding(.horizontal, 48)
              .scrollTargetLayoutIfPossible()
            }
            .frame(height: proxy.size.height)
            .scrollTargetBehaviorIfPossible()
          }
          .frame(maxWidth: .infinity)

          VStack(spacing: 12) {
            Button {
              store.send(.seeWhoSentItButtonTapped)
            } label: {
              Label("See who sent it", systemImage: "lock")
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
              let renderer = ImageRenderer(content: receiveStory)
              renderer.scale = displayScale
              store.send(.storyButtonTapped(renderer.uiImage))
            } label: {
              Label("Reply", systemImage: "camera")
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
        .background(
          LinearGradient(
            colors: [
              Color(0xFFB394FF),
              Color(0xFFFFA3E5),
              Color(0xFFFFE39B),
            ],
            startPoint: UnitPoint(x: 0.5, y: 0.0),
            endPoint: UnitPoint(x: 0.5, y: 1.0)
          )
        )
        .overlay(alignment: .topTrailing) {
          Button {
            store.send(.closeButtonTapped)
          } label: {
            Image(systemName: "xmark")
              .font(.system(size: 28, weight: .bold, design: .rounded))
              .foregroundStyle(Color.white)
          }
          .padding(.horizontal, 24)
          .buttonStyle(HoldDownButtonStyle())
        }
      }
      .task { await store.send(.onTask).finish() }
      .onAppear { store.send(.onAppear) }
    }
  }
}

#Preview {
  InboxDetailView(
    store: .init(
      initialState: InboxDetailLogic.State(),
      reducer: { InboxDetailLogic() }
    )
  )
}
