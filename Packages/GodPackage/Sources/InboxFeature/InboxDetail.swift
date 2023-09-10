import ButtonStyles
import Colors
import ComposableArchitecture
import RevealFeature
import SwiftUI
import NotificationCenterClient
import ShareScreenshotFeature

public struct InboxDetailLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    @PresentationState var destination: Destination.State?
    public init() {}
  }

  public enum Action: Equatable {
    case onTask
    case seeWhoSentItButtonTapped
    case closeButtonTapped
    case destination(PresentationAction<Destination.Action>)
    case userDidTakeScreenshotNotification
  }

  @Dependency(\.dismiss) var dismiss
  @Dependency(\.notificationCenter) var notificationCenter

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .onTask:
        return .run { send in
          for await _ in await notificationCenter.userDidTakeScreenshotNotification() {
            await send(.userDidTakeScreenshotNotification)
          }
        }
      case .seeWhoSentItButtonTapped:
        state.destination = .reveal()
        return .none

      case .closeButtonTapped:
        return .run { _ in
          await dismiss()
        }
      case .destination(.dismiss):
        state.destination = nil
        return .none

      case .destination:
        return .none
        
      case .userDidTakeScreenshotNotification:
        state.destination = .shareScreenshot()
        return .none
      }
    }
  }

  public struct Destination: Reducer {
    public enum State: Equatable {
      case reveal(RevealLogic.State = .init())
      case shareScreenshot(ShareScreenshotLogic.State = .init())
    }

    public enum Action: Equatable {
      case reveal(RevealLogic.Action)
      case shareScreenshot(ShareScreenshotLogic.Action)
    }

    public var body: some Reducer<State, Action> {
      Scope(state: /State.reveal, action: /Action.reveal) {
        RevealLogic()
      }
      Scope(state: /State.shareScreenshot, action: /Action.shareScreenshot) {
        ShareScreenshotLogic()
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
      VStack {
        VStack(spacing: 50) {
          Spacer()

          VStack(spacing: 20) {
            Image("other", bundle: .module)
              .resizable()
              .frame(width: 80, height: 80)

            Text("From someone\nin 11th grade")
          }

          VStack(spacing: 20) {
            Text("Double texts with no shame")
              .bold()

            Text("godapp.jp")
              .bold()
          }
          Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.godPurple)
        .foregroundColor(.godWhite)
        .multilineTextAlignment(.center)
        .onTapGesture {
          viewStore.send(.closeButtonTapped)
        }

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
      .background(.black)
      .task { await viewStore.send(.onTask).finish() }
      .sheet(
        store: store.scope(state: \.$destination, action: { .destination($0) }),
        state: /InboxDetailLogic.Destination.State.reveal,
        action: InboxDetailLogic.Destination.Action.reveal
      ) { store in
        RevealView(store: store)
          .presentationDetents([.fraction(0.4)])
      }
      .sheet(
        store: store.scope(state: \.$destination, action: { .destination($0) }),
        state: /InboxDetailLogic.Destination.State.shareScreenshot,
        action: InboxDetailLogic.Destination.Action.shareScreenshot
      ) { store in
        ShareScreenshotView(store: store)
          .presentationDetents([.fraction(0.3)])
          .presentationDragIndicator(.visible)
      }
    }
  }
}

struct InboxDetailViewPreviews: PreviewProvider {
  static var previews: some View {
    InboxDetailView(
      store: .init(
        initialState: InboxDetailLogic.State(),
        reducer: { InboxDetailLogic() }
      )
    )
  }
}
