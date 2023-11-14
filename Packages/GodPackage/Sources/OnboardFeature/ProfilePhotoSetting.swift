import AnalyticsClient
import ComposableArchitecture
import Contacts
import ContactsClient
import FirebaseStorage
import FirebaseStorageClient
import God
import GodClient
import PhotosUI
import Styleguide
import SwiftUI
import UserDefaultsClient

@Reducer
public struct ProfilePhotoSettingLogic {
  public init() {}

  public struct State: Equatable {
    @BindingState var photoPickerItems: [PhotosPickerItem] = []
    var image: UIImage?

    var currentUser: God.CurrentUserQuery.Data.CurrentUser?
    public init() {}
  }

  public enum Action: BindableAction {
    case onTask
    case onAppear
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

  @Dependency(\.analytics) var analytics
  @Dependency(\.godClient) var godClient
  @Dependency(\.contacts) var contactsClient
  @Dependency(\.userDefaults) var userDefaults
  @Dependency(\.firebaseStorage) var firebaseStorage

  public var body: some Reducer<State, Action> {
    BindingReducer()
    Reduce<State, Action> { state, action in
      switch action {
      case .onTask:
        return .run { send in
          await withThrowingTaskGroup(of: Void.self) { group in
            group.addTask {
              await currentUserRequest(send: send)
            }
            group.addTask {
              guard
                case .authorized = contactsClient.authorizationStatus(.contacts),
                let number = userDefaults.phoneNumber(),
                let contact = try? contactsClient.findByPhoneNumber(number: number).first
              else { return }
              await send(.loadTransferableResponse(.success(contact.imageData)))
            }
          }
        }

      case .onAppear:
        analytics.logScreen(screenName: "ProfilePhotoSetting", of: self)
        return .none

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

      case let .currentUserResponse(.success(data)):
        state.currentUser = data.currentUser
        return .none

      default:
        return .none
      }
    }
  }

  private func currentUserRequest(send: Send<Action>) async {
    do {
      for try await data in godClient.currentUser() {
        await send(.currentUserResponse(.success(data)))
      }
    } catch {
      await send(.currentUserResponse(.failure(error)))
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
          .font(.system(.title3, design: .rounded, weight: .bold))
          .foregroundStyle(Color.white)

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
          .foregroundStyle(Color.white.opacity(0.7))
          .font(.system(.body, design: .rounded))

        Spacer()

        PhotosPicker(
          selection: viewStore.$photoPickerItems,
          maxSelectionCount: 1,
          selectionBehavior: .ordered,
          matching: PHPickerFilter.images,
          preferredItemEncoding: .current
        ) {
          Text(
            viewStore.image == nil ? "Choose a photo" : "Change photo",
            bundle: .module
          )
          .font(.system(.body, design: .rounded, weight: .bold))
          .foregroundStyle(Color.white)
          .frame(height: 56)
          .frame(maxWidth: .infinity)
          .overlay(
            RoundedRectangle(cornerRadius: 56 / 2)
              .stroke(Color.white, lineWidth: 1)
          )
        }
        if viewStore.image != nil {
          Button {
            store.send(.nextButtonTapped)
          } label: {
            Text("Next", bundle: .module)
              .font(.system(.body, design: .rounded, weight: .bold))
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
            store.send(.skipButtonTapped)
          } label: {
            Text("Skip", bundle: .module)
              .foregroundStyle(Color.white)
          }
        }
      }
      .buttonStyle(HoldDownButtonStyle())
      .task { await store.send(.onTask).finish() }
      .onAppear { store.send(.onAppear) }
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
