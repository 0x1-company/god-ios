import AsyncValue
import ComposableArchitecture
import Photos
import PhotosClient
import SwiftUI

public struct ShareScreenshotLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    var asset: PHAsset
    var image = AsyncValue<UIImage?>.none
    public init(asset: PHAsset) {
      self.asset = asset
    }
  }

  public enum Action: Equatable {
    case onTask
    case lineButtonTapped
    case instagramButtonTapped
    case messagesButtonTapped
    case imageResponse(UIImage?)
  }

  @Dependency(\.photos.requestImage) var requestImage

  public var body: some Reducer<State, Action> {
    Reduce<State, Action> { state, action in
      switch action {
      case .onTask:
        let asset = state.asset
        let size = CGSize(width: 91, height: 184)
        let contentMode = PHImageContentMode.aspectFit
        state.image = .loading
        return .run { send in
          for await (image, _) in await requestImage(asset, size, contentMode, nil) {
            await send(.imageResponse(image))
          }
        }
      case .lineButtonTapped:
        return .none

      case .instagramButtonTapped:
        return .none

      case .messagesButtonTapped:
        return .none

      case let .imageResponse(image):
        state.image = .success(image)
        return .none
      }
    }
  }
}

public struct ShareScreenshotView: View {
  let store: StoreOf<ShareScreenshotLogic>

  public init(store: StoreOf<ShareScreenshotLogic>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      HStack(alignment: .top, spacing: 20) {
        Group {
          if case let .success(.some(image)) = viewStore.image {
            Image(uiImage: image)
              .resizable()
              .scaledToFit()
          }
          if case .loading = viewStore.image {
            ProgressView()
          }
        }
        .frame(width: 91, height: 184)
        .cornerRadius(16)
        .padding(.top, 12)

        VStack(spacing: 36) {
          Text("Share Screenshot", bundle: .module)
            .font(.system(.title3, design: .rounded, weight: .bold))

          HStack(spacing: 8) {
            Button {
              viewStore.send(.instagramButtonTapped)
            } label: {
              VStack(spacing: 8) {
                Color.red
                  .frame(width: 50, height: 50)
                  .clipShape(Circle())
                Text("Instagram", bundle: .module)
              }
            }

            Button {
              viewStore.send(.lineButtonTapped)
            } label: {
              VStack(spacing: 8) {
                Color.green
                  .frame(width: 50, height: 50)
                  .clipShape(Circle())
                Text("LINE", bundle: .module)
              }
            }

            Button {
              viewStore.send(.messagesButtonTapped)
            } label: {
              VStack(spacing: 8) {
                Color.green
                  .frame(width: 50, height: 50)
                  .clipShape(Circle())
                Text("Messages", bundle: .module)
              }
            }
          }
          .foregroundStyle(.primary)

          Spacer()
        }
      }
      .padding(.top, 24)
      .task { await viewStore.send(.onTask).finish() }
    }
  }
}
