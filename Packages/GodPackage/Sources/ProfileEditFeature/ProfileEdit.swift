import AnalyticsClient
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
import GradeSettingFeature
import SchoolSettingFeature

@Reducer
public struct ProfileEditLogic {
  public init() {}
  
  @Reducer
  public struct Path {
    public enum State: Equatable {
      case gradeSetting(GradeSettingLogic.State = .init())
      case schoolSetting(SchoolSettingLogic.State = .init())
    }
    public enum Action {
      case gradeSetting(GradeSettingLogic.Action)
      case schoolSetting(SchoolSettingLogic.Action)
    }
    public var body: some Reducer<State, Action> {
      Scope(state: \.gradeSetting, action: \.gradeSetting, child: GradeSettingLogic.init)
      Scope(state: \.schoolSetting, action: \.schoolSetting, child: SchoolSettingLogic.init)
    }
  }

  @Reducer
  public struct Destination {
    public enum State: Equatable {
      case manageAccount(ManageAccountLogic.State = .init())
      case deleteAccount(DeleteAccountLogic.State = .init())
      case alert(AlertState<Action.Alert>)
    }

    public enum Action {
      case manageAccount(ManageAccountLogic.Action)
      case deleteAccount(DeleteAccountLogic.Action)
      case alert(Alert)
      
      public enum Alert: Equatable {
        case okay
        case discardChanges
      }
    }

    public var body: some Reducer<State, Action> {
      Scope(state: \.manageAccount, action: \.manageAccount, child: ManageAccountLogic.init)
      Scope(state: \.deleteAccount, action: \.deleteAccount, child: DeleteAccountLogic.init)
    }
  }

  public struct State: Equatable {
    public init() {}

    var path = StackState<Path.State>()
    @PresentationState var destination: Destination.State?
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

  public enum Action: BindableAction {
    case onTask
    case onAppear
    case cancelEditButtonTapped
    case saveButtonTapped
    case currentUserResponse(TaskResult<God.CurrentUserQuery.Data>)
    case uploadResponse(TaskResult<URL>)
    case updateUsernameResponse(TaskResult<God.UpdateUsernameMutation.Data>)
    case updateUserProfileResponse(TaskResult<God.UpdateUserProfileMutation.Data>)
    case binding(BindingAction<State>)
    case loadTransferableResponse(TaskResult<Data?>)

    case schoolButtonTapped
    case restorePurchasesButtonTapped
    case manageAccountButtonTapped
    case deleteAccountButtonTapped
    case logoutButtonTapped
    case closeButtonTapped
    case path(StackAction<Path.State, Path.Action>)
    case destination(PresentationAction<Destination.Action>)
    case delegate(Delegate)

    public enum Delegate: Equatable {
      case changed
    }
  }

  @Dependency(\.dismiss) var dismiss
  @Dependency(\.godClient) var godClient
  @Dependency(\.analytics) var analytics
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

      case .onAppear:
        analytics.logScreen(screenName: "ProfileEdit", of: self)
        return .none

      case .cancelEditButtonTapped:
        state.destination = .alert(.changesNotSaved())
        return .none

      case .saveButtonTapped:
        guard
          let currentUser = state.currentUser,
          validateHiragana(for: state.firstName),
          validateHiragana(for: state.lastName)
        else {
          state.destination = .alert(.invalid())
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
        
      case .schoolButtonTapped:
        state.path.append(.gradeSetting())
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
        analytics.logEvent("sign_out", [:])
        return .run { _ in
          await userDefaults.setOnboardCompleted(false)
          try signOut()
        }

      case .closeButtonTapped:
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
        
      case .destination(.presented(.alert(.okay))):
        state.destination = nil
        return .none

      case .destination(.presented(.alert(.discardChanges))):
        return .run { _ in
          await dismiss()
        }
        
      case .path(.element(_, .gradeSetting(.delegate(.nextScreen(.none))))):
        state.path.removeAll()
        return .none
        
      case let .path(.element(_, .gradeSetting(.delegate(.nextScreen(.some(generation)))))):
        print(generation)
        state.path.append(.schoolSetting())
        return .none
        
      case let .path(.element(_, .schoolSetting(.delegate(.nextScreen(.some(schoolId)))))):
        print(schoolId)
        state.path.removeAll()
        return .none

      default:
        return .none
      }
    }
    .ifLet(\.$destination, action: \.destination) {
      Destination()
    }
    .forEach(\.path, action: \.path) {
      Path()
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
    NavigationStackStore(store.scope(state: \.path, action: ProfileEditLogic.Action.path)) {
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
                  .foregroundStyle(Color.godWhite)
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
                  .foregroundStyle(Color.godTextSecondaryLight)
                  .frame(width: 108, alignment: .leading)

                Text(viewStore.gender, bundle: .module)
                  .multilineTextAlignment(.leading)
                  .frame(maxWidth: .infinity, alignment: .leading)
                  .font(.body)
                  .foregroundStyle(Color.godBlack)
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
                .foregroundStyle(Color.godTextSecondaryLight)
                .font(.system(.caption, design: .rounded, weight: .bold))

              Button {
                store.send(.schoolButtonTapped)
              } label: {
                VStack(alignment: .center, spacing: 0) {
                  HStack(alignment: .center, spacing: 8) {
                    Text(Image(systemName: "house.fill"))
                      .foregroundStyle(Color.godTextSecondaryLight)
                      .font(.system(.body, design: .rounded))

                    Text(viewStore.currentUser?.school?.name ?? "")
                      .font(.system(.body, design: .rounded))
                      .foregroundStyle(Color.godBlack)
                      .frame(maxWidth: .infinity, alignment: .leading)
                  }
                  .padding(.horizontal, 12)
                  .frame(maxWidth: .infinity)
                  .frame(height: 52)

                  Separator()

                  HStack(alignment: .center, spacing: 8) {
                    Text(Image(systemName: "graduationcap.fill"))
                      .foregroundStyle(Color.godTextSecondaryLight)
                      .font(.system(.body, design: .rounded))

                    Text(viewStore.currentUser?.grade ?? "")
                      .font(.system(.body, design: .rounded))
                      .foregroundStyle(Color.godBlack)
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
            }

            VStack(alignment: .leading, spacing: 8) {
              Text("ACCOUNT SETTING", bundle: .module)
                .font(.system(.caption, design: .rounded, weight: .bold))
                .foregroundStyle(Color.godTextSecondaryLight)
  //            CornerRadiusBorderButton("Restore Purchases", systemImage: "clock.arrow.circlepath") {
  //              store.send(.restorePurchasesButtonTapped)
  //            }
  //
  //            CornerRadiusBorderButton("Manage Account", systemImage: "gearshape.fill") {
  //              store.send(.manageAccountButtonTapped)
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
                store.send(.cancelEditButtonTapped)
              } label: {
                Text("Cancel", bundle: .module)
                  .font(.system(.body, design: .rounded))
              }
              .foregroundStyle(.primary)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
              Button {
                store.send(.saveButtonTapped)
              } label: {
                Text("Save", bundle: .module)
                  .font(.system(.body, design: .rounded))
              }
              .foregroundStyle(.primary)
            }
          } else {
            ToolbarItem(placement: .navigationBarLeading) {
              Button {
                store.send(.closeButtonTapped)
              } label: {
                Text("Close", bundle: .module)
                  .font(.system(.body, design: .rounded))
              }
              .foregroundStyle(.primary)
            }
          }
        }
        .task { await store.send(.onTask).finish() }
        .onAppear { store.send(.onAppear) }
        .alert(
          store: store.scope(state: \.$destination, action: ProfileEditLogic.Action.destination),
          state: /ProfileEditLogic.Destination.State.alert,
          action: ProfileEditLogic.Destination.Action.alert
        )
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
    } destination: { initialState in
      switch initialState {
      case .gradeSetting:
        CaseLet(
          /ProfileEditLogic.Path.State.gradeSetting,
          action: ProfileEditLogic.Path.Action.gradeSetting,
          then: GradeSettingView.init(store:)
        )
      case .schoolSetting:
        CaseLet(
          /ProfileEditLogic.Path.State.schoolSetting,
          action: ProfileEditLogic.Path.Action.schoolSetting,
          then: SchoolSettingView.init(store:)
        )
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
          .foregroundStyle(Color.godTextSecondaryLight)
          .frame(width: 108, alignment: .leading)

        TextField("", text: $text)
          .multilineTextAlignment(.leading)
          .textFieldStyle(PlainTextFieldStyle())
          .font(.body)
          .foregroundStyle(Color.godBlack)
      }
      .padding(.horizontal, 12)
      .frame(maxWidth: .infinity)
      .frame(height: 52)
    }
  }
}

private extension AlertState where Action == ProfileEditLogic.Destination.Action.Alert {
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
