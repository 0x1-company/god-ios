import ButtonStyles
import Colors
import ComposableArchitecture
import FirebaseStorage
import FirebaseStorageClient
import God
import GodClient
import PhotosUI
import SwiftUI

public struct ProfilePhotoSettingLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    @BindingState var photoPickerItems: [PhotosPickerItem] = []
    var image: UIImage?

    var currentUser: God.CurrentUserQuery.Data.CurrentUser?
    public init() {}
  }

  public enum Action: Equatable, BindableAction {
    case onTask
    case skipButtonTapped
    case nextButtonTapped
    case binding(BindingAction<State>)
    case loadTransferableResponse(TaskResult<Data?>)
    case uploadResponse(TaskResult<URL>)
    case currentUserResponse(TaskResult<God.CurrentUserQuery.Data>)
    case delegate(Delegate)

    public enum Delegate: Equatable {
      case nextScreen
    }
  }

  @Dependency(\.godClient) var godClient
  @Dependency(\.firebaseStorage) var firebaseStorage

  public var body: some Reducer<State, Action> {
    BindingReducer()
    Reduce<State, Action> { state, action in
      switch action {
      case .onTask:
        return .run { send in
          for try await data in godClient.currentUser() {
            await send(.currentUserResponse(.success(data)))
          }
        } catch: { error, send in
          await send(.currentUserResponse(.failure(error)))
        }

      case .skipButtonTapped:
        return .send(.delegate(.nextScreen))

      case .nextButtonTapped:
        return .send(.delegate(.nextScreen))

      case .binding:
        guard let photoPickerItem = state.photoPickerItems.first else { return .none }
        return .run { send in
          await send(.loadTransferableResponse(TaskResult {
            try await photoPickerItem.loadTransferable(type: Data.self)
          }))
        }

      case let .loadTransferableResponse(.success(.some(data))):
        state.image = UIImage(data: data)
        guard let userId = state.currentUser?.id else { return .none }
        return .run { send in
          await send(.uploadResponse(TaskResult {
            try await firebaseStorage.upload("users/profile_images/\(userId)", data)
          }))
        }

      case .loadTransferableResponse:
        return .none

      case .uploadResponse(.success):
        return .none

      case .uploadResponse:
        return .none

      case let .currentUserResponse(.success(data)):
        state.currentUser = data.currentUser
        return .none

      case .currentUserResponse(.failure):
        return .none

      case .delegate:
        return .none
      }
    }
  }
}

public struct ProfilePhotoSettingView: View {
  let store: StoreOf<ProfilePhotoSettingLogic>

  public init(store: StoreOf<ProfilePhotoSettingLogic>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      VStack(spacing: 24) {
        Spacer()

        Text("Add a profile photo", bundle: .module)
          .bold()
          .font(.title3)
          .foregroundColor(Color.white)

        PhotosPicker(
          selection: viewStore.$photoPickerItems,
          maxSelectionCount: 1,
          selectionBehavior: .ordered,
          matching: PHPickerFilter.images,
          preferredItemEncoding: .current
        ) {
          Group {
            if let image = viewStore.image {
              Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 120, height: 120)
                .clipShape(Circle())
            } else {
              Image(ImageResource.emptyPicture)
                .resizable()
                .scaledToFill()
                .frame(width: 120, height: 120)
                .clipShape(Circle())
            }
          }
        }

        Text("Add a photo so your friends can find you", bundle: .module)
          .foregroundColor(Color.white.opacity(0.7))

        Spacer()

        PhotosPicker(
          selection: viewStore.$photoPickerItems,
          maxSelectionCount: 1,
          selectionBehavior: .ordered,
          matching: PHPickerFilter.images,
          preferredItemEncoding: .current
        ) {
          Text(
            viewStore.photoPickerItems.isEmpty ? "Choose a photo" : "Change photo",
            bundle: .module
          )
          .bold()
          .foregroundColor(Color.white)
          .frame(height: 56)
          .frame(maxWidth: .infinity)
          .overlay(
            RoundedRectangle(cornerRadius: 56 / 2)
              .stroke(Color.white, lineWidth: 1)
          )
        }
        if !viewStore.photoPickerItems.isEmpty {
          Button {
            viewStore.send(.nextButtonTapped)
          } label: {
            Text("Next", bundle: .module)
              .bold()
              .frame(height: 56)
              .frame(maxWidth: .infinity)
              .background(Color.white)
              .clipShape(Capsule())
          }
        }
      }
      .padding(.horizontal, 24)
      .background(Color.godService)
      .multilineTextAlignment(.center)
      .toolbar {
        if viewStore.photoPickerItems.isEmpty {
          Button {
            viewStore.send(.skipButtonTapped)
          } label: {
            Text("Skip", bundle: .module)
              .foregroundStyle(Color.white)
          }
        }
      }
      .buttonStyle(HoldDownButtonStyle())
      .task { await viewStore.send(.onTask).finish() }
    }
  }
}

#Preview {
  ProfilePhotoSettingView(
    store: .init(
      initialState: ProfilePhotoSettingLogic.State(),
      reducer: { ProfilePhotoSettingLogic() }
    )
  )
}
