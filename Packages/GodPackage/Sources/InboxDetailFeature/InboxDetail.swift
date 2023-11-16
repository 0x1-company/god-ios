import AnimationDisableTransaction
import AnalyticsClient
import Styleguide
import ComposableArchitecture
import SwiftUI
import InboxStoryFeature
import RevealFeature
import GodModeFeature

@Reducer
public struct InboxDetailLogic {
  public init() {}

  public struct State: Equatable {
    public init() {}
  }

  public enum Action {
    case onTask
    case onAppear
    case closeButtonTapped
    case storyButtonTapped
  }

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
        
      default:
        return .none
      }
    }
  }
}

public struct InboxDetailView: View {
  let store: StoreOf<InboxDetailLogic>

  public init(store: StoreOf<InboxDetailLogic>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
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

        VStack(spacing: 20) {
          Button {
            store.send(.storyButtonTapped)
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
            store.send(.storyButtonTapped)
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
      .task { await store.send(.onTask).finish() }
      .onAppear { store.send(.onAppear) }
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
  }
}

extension View {
  @ViewBuilder
  func scrollTargetLayoutIfPossible(isEnabled: Bool = true) -> some View {
    if #available(iOS 17.0, *) {
      self.scrollTargetLayout(isEnabled: isEnabled)
    } else {
      self
    }
  }

  @ViewBuilder
  func scrollTargetBehaviorIfPossible() -> some View {
    if #available(iOS 17.0, *) {
      self.scrollTargetBehavior(.paging)
    } else {
      self
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
