import AsyncValue
import ButtonStyles
import Colors
import ComposableArchitecture
import FirebaseAuthClient
import God
import GodClient
import ManageAccountFeature
import SwiftUI
import UserDefaultsClient
import PhotosUI

public struct ProfileEditLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    public init() {}

    @PresentationState var manageAccount: ManageAccountLogic.State?
    @PresentationState var alert: AlertState<Action.Alert>?
    @BindingState var photoPickerItems: [PhotosPickerItem] = []
    @BindingState var firstName: String = ""
    @BindingState var lastName: String = ""
    @BindingState var username: String = ""
    var image: UIImage?
    var currentUser: God.CurrentUserQuery.Data.CurrentUser?
    
    var isUserProfileChanges: Bool {
      guard let currentUser else {
        return false
      }
      return firstName != currentUser.firstName
      || lastName != currentUser.lastName
      || username != currentUser.username
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
    case updateUsernameResponse(TaskResult<God.UpdateUsernameMutation.Data>)
    case updateUserProfileResponse(TaskResult<God.UpdateUserProfileMutation.Data>)
    case binding(BindingAction<State>)
    case loadTransferableResponse(TaskResult<Data?>)

    case restorePurchasesButtonTapped
    case manageAccountButtonTapped
    case logoutButtonTapped
    case closeButtonTapped
    case manageAccount(PresentationAction<ManageAccountLogic.Action>)
    case alert(PresentationAction<Alert>)

    public enum Alert: Equatable {
      case nameCanOnlyBeChangedOnce(NameCanOnlyBeChangedOnce)
      case changesNotSaved(ChangesNotSaved)

      public enum NameCanOnlyBeChangedOnce: Equatable {
        case changeNameButtonTapped
        case cancelButtonTapped
      }

      public enum ChangesNotSaved: Equatable {
        case discardChangesButtonTapped
        case cancelButtonTapped
      }
    }
  }

  @Dependency(\.dismiss) var dismiss
  @Dependency(\.godClient) var godClient
  @Dependency(\.userDefaults) var userDefaults
  @Dependency(\.firebaseAuth.signOut) var signOut

  private enum Cancel {
    case currentUser
  }

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
        .cancellable(id: Cancel.currentUser)

      case .cancelEditButtonTapped:
        state.alert = .changesNotSaved()
        return .none

      case .saveButtonTapped:
        guard let currentUser = state.currentUser else { return .none }
        return .merge(
          .run { [state] send in
            if state.username != currentUser.username {
              let data = try await godClient.updateUsername(.init(username: state.username))
              await send(.updateUsernameResponse(.success(data)))
            }
          } catch: { error, send in
            await send(.updateUsernameResponse(.failure(error)))
          },
          .run { [state] send in
            if state.firstName != currentUser.firstName ||
              state.lastName != currentUser.lastName
            {
              let data = try await godClient.updateUserProfile(.init(
                firstName: state.firstName != currentUser.firstName ? .some(state.firstName) : .null,
                lastName: state.lastName != currentUser.lastName ? .some(state.lastName) : .null
              ))
              await send(.updateUserProfileResponse(.success(data)))
            }
          } catch: { error, send in
            await send(.updateUserProfileResponse(.failure(error)))
          }
        )

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
        return .none

      case .updateUsernameResponse(.failure):
        return .none

      case let .updateUserProfileResponse(.success(response)):
        state.firstName = response.updateUserProfile.firstName
        state.lastName = response.updateUserProfile.lastName
        return .none

      case .updateUserProfileResponse(.failure):
        return .none

      case .restorePurchasesButtonTapped:
        return .none

      case .manageAccountButtonTapped:
        state.manageAccount = .init()
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

      case .alert(.presented(.changesNotSaved(.discardChangesButtonTapped))):
        guard let currentUser = state.currentUser else { return .none }
        state.firstName = currentUser.firstName
        state.lastName = currentUser.lastName
        state.username = currentUser.username ?? ""
        return .none
        
      case .binding(\.$photoPickerItems):
        guard let photoPickerItem = state.photoPickerItems.first else { return .none }
        return .run { send in
          await send(.loadTransferableResponse(TaskResult {
            try await photoPickerItem.loadTransferable(type: Data.self)
          }))
        }
        
      case let .loadTransferableResponse(.success(.some(data))):
        state.image = UIImage(data: data)
        return .none

      default:
        return .none
      }
    }
    .ifLet(\.$manageAccount, action: /Action.manageAccount) {
      ManageAccountLogic()
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
              if let imageURL = viewStore.currentUser?.imageURL {
                AsyncImage(url: URL(string: imageURL)) { image in
                  image.resizable()
                } placeholder: {
                  Color.red
                }

              } else {
                Image(uiImage: viewStore.image ?? UIImage())
                  .resizable()
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

          VStack(alignment: .center, spacing: 0) {
            GodTextField(
              text: viewStore.$firstName,
              fieldName: "First Name"
            )

            Separator()

            GodTextField(
              text: viewStore.$lastName,
              fieldName: "Last Name"
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
            CornerRadiusBorderButton("Restore Purchases", systemImage: "clock.arrow.circlepath") {
              viewStore.send(.restorePurchasesButtonTapped)
            }

            CornerRadiusBorderButton("Manage Account", systemImage: "gearshape.fill") {
              viewStore.send(.manageAccountButtonTapped)
            }

            CornerRadiusBorderButton("Logout", systemImage: "rectangle.portrait.and.arrow.right") {
              viewStore.send(.logoutButtonTapped)
            }
          }
        }
        .padding(.all, 24)
      }
      .navigationTitle(Text("Edit Profile", bundle: .module))
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        if viewStore.state.isUserProfileChanges {
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
      .sheet(
        store: store.scope(
          state: \.$manageAccount,
          action: ProfileEditLogic.Action.manageAccount
        ),
        content: { store in
          NavigationStack {
            ManageAccountView(store: store)
          }
        }
      )
      .alert(store: store.scope(state: \.$alert, action: ProfileEditLogic.Action.alert))
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
  static func nameCanOnlyBeChangedOnce() -> Self {
    Self {
      TextState("ちょっと待って！")
    } actions: {
      ButtonState(role: .cancel, action: .nameCanOnlyBeChangedOnce(.cancelButtonTapped)) {
        TextState("キャンセル")
      }
      ButtonState(role: .destructive, action: .nameCanOnlyBeChangedOnce(.changeNameButtonTapped)) {
        TextState("名前を変更")
      }
    } message: {
      TextState("名前は一度しか変更できません")
    }
  }

  static func changesNotSaved() -> Self {
    Self {
      TextState("本当に大丈夫？")
    } actions: {
      ButtonState(role: .destructive, action: .changesNotSaved(.discardChangesButtonTapped)) {
        TextState("変更を破棄")
      }
      ButtonState(role: .cancel, action: .changesNotSaved(.cancelButtonTapped)) {
        TextState("キャンセル")
      }
    } message: {
      TextState("保存していない変更があります")
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
