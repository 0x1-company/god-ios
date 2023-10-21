import AsyncValue
import ComposableArchitecture
import DeleteAccountFeature
import FirebaseAuthClient
import FirebaseStorage
import FirebaseStorageClient
import God
import GodClient
import ManageAccountFeature
import PhotosUI
import ProfileImage
import StringHelpers
import Styleguide
import SwiftUI
import UserDefaultsClient

public struct ProfileEditLogic: Reducer {
  public init() {}
  public struct Destination: Reducer {
    public enum State: Equatable {
      case manageAccount(ManageAccountLogic.State = .init())
      case deleteAccount(DeleteAccountLogic.State = .init())
    }
    public enum Action: Equatable {
      case manageAccount(ManageAccountLogic.Action)
      case deleteAccount(DeleteAccountLogic.Action)
    }
    public var body: some Reducer<State, Action> {
      Scope(state: /State.manageAccount, action: /Action.manageAccount, child: ManageAccountLogic.init)
      Scope(state: /State.deleteAccount, action: /Action.deleteAccount, child: DeleteAccountLogic.init)
    }
  }

  public struct State: Equatable {
    public init() {}

    @PresentationState var destination: Destination.State?
    @PresentationState var alert: AlertState<Action.Alert>?
    @BindingState var photoPickerItems: [PhotosPickerItem] = []
    @BindingState var firstName: String = ""
    @BindingState var lastName: String = ""
    @BindingState var username: String = ""
    var imageData: Data?
    var currentUser: God.CurrentUserQuery.Data.CurrentUser?

    var isUserProfileChanges: Bool {
      guard let currentUser else {
        return false
      }
      return firstName != currentUser.firstName
        || lastName != currentUser.lastName
        || username != currentUser.username
        || imageData != nil
    }

    var gender: LocalizedStringKey {
      switch currentUser?.gender.value {
      case .male:
        return "Male"
      case .female:
        return "Female"
      case .other:
        return "Non-Binary"
      default:
        return ""
      }
    }
  }

  public enum Action: Equatable, BindableAction {
    case onTask
    case cancelEditButtonTapped
    case saveButtonTapped
    case currentUserResponse(TaskResult<God.CurrentUserQuery.Data>)
    case uploadResponse(TaskResult<URL>)
    case updateUsernameResponse(TaskResult<God.UpdateUsernameMutation.Data>)
    case updateUserProfileResponse(TaskResult<God.UpdateUserProfileMutation.Data>)
    case binding(BindingAction<State>)
    case loadTransferableResponse(TaskResult<Data?>)

    case restorePurchasesButtonTapped
    case manageAccountButtonTapped
    case deleteAccountButtonTapped
    case logoutButtonTapped
    case closeButtonTapped
    case destination(PresentationAction<Destination.Action>)
    case alert(PresentationAction<Alert>)
    case delegate(Delegate)

    public enum Alert: Equatable {
      case okay
      case discardChanges
    }

    public enum Delegate: Equatable {
      case changed
    }
  }

  @Dependency(\.dismiss) var dismiss
  @Dependency(\.godClient) var godClient
  @Dependency(\.userDefaults) var userDefaults
  @Dependency(\.firebaseAuth.signOut) var signOut
  @Dependency(\.firebaseStorage) var firebaseStorage

  private enum Cancel {
    case currentUser
  }

  public var body: some Reducer<State, Action> {
    BindingReducer()
    Reduce<State, Action> { state, action in
      switch action {
      case .onTask:
        return .run { send in
          await currentUserRequest(send: send)
        }
        .cancellable(id: Cancel.currentUser, cancelInFlight: true)

      case .cancelEditButtonTapped:
        state.alert = .changesNotSaved()
        return .none

      case .saveButtonTapped:
        guard
          let currentUser = state.currentUser,
          validateHiragana(for: state.firstName),
          validateHiragana(for: state.lastName)
        else {
          state.alert = .invalid()
          return .none
        }
        return .run { [state] send in
          await withThrowingTaskGroup(of: Void.self) { group in
            if state.username != currentUser.username {
              group.addTask {
                await send(.updateUsernameResponse(TaskResult {
                  try await godClient.updateUsername(.init(username: state.username))
                }))
              }
            }

            if state.firstName != currentUser.firstName || state.lastName != currentUser.lastName {
              group.addTask {
                await send(.updateUserProfileResponse(TaskResult {
                  try await godClient.updateUserProfile(.init(
                    firstName: state.firstName != currentUser.firstName ? .some(state.firstName) : .null,
                    lastName: state.lastName != currentUser.lastName ? .some(state.lastName) : .null
                  ))
                }))
              }
            }

            if let imageData = state.imageData, let userId = state.currentUser?.id {
              group.addTask {
                await send(.uploadResponse(TaskResult {
                  try await firebaseStorage.upload("users/profile_images/\(userId)", imageData)
                }))
              }
            }
          }
          await currentUserRequest(send: send)
        }

      case let .currentUserResponse(.success(data)):
        state.currentUser = data.currentUser
        state.firstName = data.currentUser.firstName
        state.lastName = data.currentUser.lastName
        state.username = data.currentUser.username ?? ""
        return .none

      case let .updateUsernameResponse(.success(response)):
        if let username = response.updateUsername.username {
          state.username = username
        }
        return .send(.delegate(.changed))

      case .updateUsernameResponse(.failure):
        return .none

      case let .updateUserProfileResponse(.success(response)):
        state.firstName = response.updateUserProfile.firstName
        state.lastName = response.updateUserProfile.lastName
        return .send(.delegate(.changed))

      case .updateUserProfileResponse(.failure):
        return .none

      case .restorePurchasesButtonTapped:
        return .none

      case .manageAccountButtonTapped:
        state.destination = .manageAccount()
        return .none
        
      case .deleteAccountButtonTapped:
        state.destination = .deleteAccount()
        return .none

      case .logoutButtonTapped:
        return .run { _ in
          await userDefaults.setOnboardCompleted(false)
          try signOut()
        }

      case .closeButtonTapped:
        return .run { _ in
          await dismiss()
        }

      case .alert(.presented(.okay)):
        state.alert = nil
        return .none

      case .alert(.presented(.discardChanges)):
        return .run { _ in
          await dismiss()
        }

      case .binding(\.$photoPickerItems):
        guard let photoPickerItem = state.photoPickerItems.first else { return .none }
        return .run { send in
          await send(.loadTransferableResponse(TaskResult {
            try await photoPickerItem.loadTransferable(type: Data.self)
          }))
        }

      case let .loadTransferableResponse(.success(.some(data))):
        state.imageData = data
        return .none

      case .uploadResponse:
        URLCache.shared.removeAllCachedResponses()
        state.imageData = nil
        return .none

      default:
        return .none
      }
    }
    .ifLet(\.$destination, action: /Action.destination) {
      Destination()
    }
  }

  func currentUserRequest(send: Send<Action>) async {
    do {
      for try await data in godClient.currentUser() {
        await send(.currentUserResponse(.success(data)))
      }
    } catch {
      await send(.currentUserResponse(.failure(error)))
    }
  }
}

public struct ProfileEditView: View {
  let store: StoreOf<ProfileEditLogic>

  public init(store: StoreOf<ProfileEditLogic>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      ScrollView(.vertical) {
        VStack(spacing: 24) {
          PhotosPicker(
            selection: viewStore.$photoPickerItems,
            maxSelectionCount: 1,
            selectionBehavior: .ordered,
            matching: PHPickerFilter.images,
            preferredItemEncoding: .current
          ) {
            Group {
              if let imageData = viewStore.imageData, let image = UIImage(data: imageData) {
                Image(uiImage: image)
                  .resizable()
              } else if let user = viewStore.currentUser {
                ProfileImage(
                  urlString: user.imageURL,
                  name: user.firstName,
                  size: 145
                )
              }
            }
            .scaledToFill()
            .frame(width: 145, height: 145)
            .clipShape(Circle())
            .overlay(
              Image(systemName: "camera.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.godWhite)
                .frame(width: 40, height: 40)
                .shadow(color: .godBlack.opacity(0.5), radius: 4, y: 2)
            )
          }
          .buttonStyle(HoldDownButtonStyle())

          VStack(alignment: .center, spacing: 0) {
            GodTextField(
              text: viewStore.$lastName,
              fieldName: "Last Name"
            )

            Separator()

            GodTextField(
              text: viewStore.$firstName,
              fieldName: "First Name"
            )

            Separator()

            GodTextField(
              text: viewStore.$username,
              fieldName: "username"
            )

            Separator()

            HStack(alignment: .center, spacing: 0) {
              Text("Gender", bundle: .module)
                .font(.body)
                .foregroundColor(.godTextSecondaryLight)
                .frame(width: 108, alignment: .leading)

              Text(viewStore.gender, bundle: .module)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.body)
                .foregroundColor(.godBlack)
            }
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
          }
          .overlay(
            RoundedRectangle(cornerRadius: 16)
              .stroke(Color.godSeparator)
          )

          VStack(alignment: .leading, spacing: 8) {
            Text("SCHOOL", bundle: .module)
              .font(.caption)
              .bold()
              .foregroundColor(.godTextSecondaryLight)

            VStack(alignment: .center, spacing: 0) {
              HStack(alignment: .center, spacing: 8) {
                Text(Image(systemName: "house.fill"))
                  .foregroundColor(.godTextSecondaryLight)
                  .font(.body)

                Text(viewStore.currentUser?.school?.name ?? "")
                  .font(.body)
                  .foregroundColor(.godBlack)
                  .frame(maxWidth: .infinity, alignment: .leading)
              }
              .padding(.horizontal, 12)
              .frame(maxWidth: .infinity)
              .frame(height: 52)

              Separator()

              HStack(alignment: .center, spacing: 8) {
                Text(Image(systemName: "graduationcap.fill"))
                  .foregroundColor(.godTextSecondaryLight)
                  .font(.body)

                Text(viewStore.currentUser?.grade ?? "")
                  .font(.body)
                  .foregroundColor(.godBlack)
                  .frame(maxWidth: .infinity, alignment: .leading)
              }
              .padding(.horizontal, 12)
              .frame(maxWidth: .infinity)
              .frame(height: 52)
            }
            .overlay(
              RoundedRectangle(cornerRadius: 16)
                .stroke(Color.godSeparator)
            )
          }

          VStack(alignment: .leading, spacing: 8) {
            Text("ACCOUNT SETTING", bundle: .module)
              .font(.caption)
              .bold()
              .foregroundColor(.godTextSecondaryLight)
//            CornerRadiusBorderButton("Restore Purchases", systemImage: "clock.arrow.circlepath") {
//              viewStore.send(.restorePurchasesButtonTapped)
//            }
//
//            CornerRadiusBorderButton("Manage Account", systemImage: "gearshape.fill") {
//              viewStore.send(.manageAccountButtonTapped)
//            }

            CornerRadiusBorderButton("Logout", systemImage: "rectangle.portrait.and.arrow.right") {
              store.send(.logoutButtonTapped)
            }
            
            CornerRadiusBorderButton("Delete Account", systemImage: "trash") {
              store.send(.deleteAccountButtonTapped)
            }
            .foregroundStyle(Color.red)
          }
        }
        .padding(.all, 24)
      }
      .navigationTitle(Text("Edit Profile", bundle: .module))
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        if viewStore.isUserProfileChanges {
          ToolbarItem(placement: .navigationBarLeading) {
            Button {
              viewStore.send(.cancelEditButtonTapped)
            } label: {
              Text("Cancel", bundle: .module)
            }
            .foregroundColor(.primary)
          }
          ToolbarItem(placement: .navigationBarTrailing) {
            Button {
              viewStore.send(.saveButtonTapped)
            } label: {
              Text("Save", bundle: .module)
            }
            .foregroundColor(.primary)
          }
        } else {
          ToolbarItem(placement: .navigationBarLeading) {
            Button {
              viewStore.send(.closeButtonTapped)
            } label: {
              Text("Close", bundle: .module)
            }
            .foregroundColor(.primary)
          }
        }
      }
      .task { await viewStore.send(.onTask).finish() }
      .alert(store: store.scope(state: \.$alert, action: ProfileEditLogic.Action.alert))
      .sheet(
        store: store.scope(state: \.$destination, action: ProfileEditLogic.Action.destination),
        state: /ProfileEditLogic.Destination.State.manageAccount,
        action: ProfileEditLogic.Destination.Action.manageAccount
      ) { store in
        NavigationStack {
          ManageAccountView(store: store)
        }
      }
      .sheet(
        store: store.scope(state: \.$destination, action: ProfileEditLogic.Action.destination),
        state: /ProfileEditLogic.Destination.State.deleteAccount,
        action: ProfileEditLogic.Destination.Action.deleteAccount
      ) { store in
        NavigationStack {
          DeleteAccountView(store: store)
        }
      }
    }
  }

  private struct Separator: View {
    var body: some View {
      Color.godSeparator
        .frame(height: 1)
        .frame(maxWidth: .infinity)
    }
  }

  private struct GodTextField: View {
    @Binding var text: String
    var fieldName: LocalizedStringKey

    var body: some View {
      HStack(alignment: .center, spacing: 0) {
        Text(fieldName, bundle: .module)
          .font(.body)
          .foregroundColor(.godTextSecondaryLight)
          .frame(width: 108, alignment: .leading)

        TextField("", text: $text)
          .multilineTextAlignment(.leading)
          .textFieldStyle(PlainTextFieldStyle())
          .font(.body)
          .foregroundColor(.godBlack)
      }
      .padding(.horizontal, 12)
      .frame(maxWidth: .infinity)
      .frame(height: 52)
    }
  }
}

private extension AlertState where Action == ProfileEditLogic.Action.Alert {
  static func changesNotSaved() -> Self {
    Self {
      TextState("Are you sure?", bundle: .module)
    } actions: {
      ButtonState(role: .destructive, action: .discardChanges) {
        TextState("Discard Changes", bundle: .module)
      }
      ButtonState(role: .cancel) {
        TextState("Cancel", bundle: .module)
      }
    } message: {
      TextState("You haven't saved your changes", bundle: .module)
    }
  }

  static func invalid() -> Self {
    Self {
      TextState("Error", bundle: .module)
    } actions: {
      ButtonState(action: .okay) {
        TextState("OK", bundle: .module)
      }
    } message: {
      TextState("Only hiragana can be used.", bundle: .module)
    }
  }
}

#Preview {
  NavigationStack {
    ProfileEditView(
      store: .init(
        initialState: ProfileEditLogic.State(),
        reducer: { ProfileEditLogic() }
      )
    )
  }
}
