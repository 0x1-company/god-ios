import ButtonStyles
import Colors
import ComposableArchitecture
import NotificationCenterClient
import Photos
import PhotosClient
import RevealFeature
import ShareScreenshotFeature
import SwiftUI

public struct InboxDetailLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    @PresentationState var destination: Destination.State?
    let isInGodMode: Bool
    public init(isInGodMode: Bool) {
      self.isInGodMode = isInGodMode
    }
  }

  public enum Action: Equatable {
    case onTask
    case seeWhoSentItButtonTapped
    case closeButtonTapped
    case destination(PresentationAction<Destination.Action>)
    case userDidTakeScreenshotNotification
  }

  @Dependency(\.dismiss) var dismiss
  @Dependency(\.photos) var photos
  @Dependency(\.notificationCenter) var notificationCenter

  public var body: some Reducer<State, Action> {
    Reduce<State, Action> { state, action in
      switch action {
      case .onTask:
        return .run { send in
          _ = await photos.requestAuthorization(.readWrite)
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
        guard case .authorized = photos.authorizationStatus(.readWrite)
        else { return .none }
        let options = PHFetchOptions()
        options.fetchLimit = 1
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        guard let asset = photos.fetchAssets(options).first
        else { return .none }
        state.destination = .shareScreenshot(
          ShareScreenshotLogic.State(asset: asset)
        )
        return .none
      }
    }
  }

  public struct Destination: Reducer {
    public enum State: Equatable {
      case reveal(RevealLogic.State = .init())
      case shareScreenshot(ShareScreenshotLogic.State)
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
            Image(.other)
              .resizable()
              .frame(width: 80, height: 80)

            Text("From someone\nin 11th grade", bundle: .module)
          }

          VStack(spacing: 20) {
            Text("Double texts with no shame", bundle: .module)
              .bold()

            Text("godapp.jp", bundle: .module)
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

#Preview {
  InboxDetailView(
    store: .init(
      initialState: InboxDetailLogic.State(
        isInGodMode: false
      ),
      reducer: { InboxDetailLogic() }
    )
  )
}
