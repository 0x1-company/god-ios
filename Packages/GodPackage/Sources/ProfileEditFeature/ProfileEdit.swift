import AsyncValue
import ButtonStyles
import Colors
import ComposableArchitecture
import FirebaseAuthClient
import God
import GodClient
import LabeledButton
import ManageAccountFeature
import SwiftUI
import UserDefaultsClient

public struct ProfileEditLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    public struct UserProfile: Equatable {
      var firstName: String
      var lastName: String
      var username: String?
    }

    @PresentationState var manageAccount: ManageAccountLogic.State?
    @PresentationState var alert: AlertState<Action.Alert>?
    var user = AsyncValue<UserProfile>.none
    var isUserProfileChanges: Bool {
      if case let .success(currentUser) = user {
        return firstName != currentUser.firstName ||
          lastName != currentUser.lastName ||
          username != currentUser.username
      }
      return false
    }

    @BindingState var firstName: String = ""
    @BindingState var lastName: String = ""
    @BindingState var username: String = ""

    public init() {}
  }

  public enum Action: Equatable, BindableAction {
    case onTask
    case cancelEditButtonTapped
    case saveButtonTapped
    case currentUserResponse(TaskResult<God.CurrentUserQuery.Data>)
    case updateUsernameResponse(TaskResult<God.UpdateUsernameMutation.Data>)
    case updateUserProfileResponse(TaskResult<God.UpdateUserProfileMutation.Data>)
    case binding(BindingAction<State>)

    case restorePurchasesButtonTapped
    case manageAccountButtonTapped
    case logoutButtonTapped
    case closeButtonTapped
    case manageAccount(PresentationAction<ManageAccountLogic.Action>)
    case alert(PresentationAction<Alert>)

    public enum Alert: Equatable {
      public enum NameCanOnlyBeChangedOnce: Equatable {
        case changeNameButtonTapped
        case cancelButtonTapped
      }

      public enum ChangesNotSaved: Equatable {
        case discardChangesButtonTapped
        case cancelButtonTapped
      }

      case nameCanOnlyBeChangedOnce(NameCanOnlyBeChangedOnce)
      case changesNotSaved(ChangesNotSaved)
    }
  }

  @Dependency(\.dismiss) var dismiss
  @Dependency(\.userDefaults) var userDefaults
  @Dependency(\.firebaseAuth.signOut) var signOut
  @Dependency(\.godClient) var godClient

  private enum CancelId {
    case currentUserRequest
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
        .cancellable(id: CancelId.currentUserRequest)

      case .cancelEditButtonTapped:
        state.alert = .changesNotSaved()
        return .none

      case .saveButtonTapped:
        guard case let .success(currentUser) = state.user else { return .none }
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

      case let .currentUserResponse(.success(response)):
        let responseUser = response.currentUser
        state.user = .success(.init(
          firstName: responseUser.firstName,
          lastName: responseUser.lastName,
          username: responseUser.username
        ))
        state.firstName = responseUser.firstName
        state.lastName = responseUser.lastName
        state.username = responseUser.username ?? ""
        return .none

      case .currentUserResponse(.failure):
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

      case .manageAccount:
        return .none
      case .alert(.presented(.changesNotSaved(.discardChangesButtonTapped))):
        guard case let .success(user) = state.user else {
          assertionFailure()
          return .none
        }
        state.firstName = user.firstName
        state.lastName = user.lastName
        state.username = user.username ?? ""
        return .none
      case .alert(.presented(.nameCanOnlyBeChangedOnce(.changeNameButtonTapped))):
        // TODO: 一度しか変更できません
        return .none
      case .alert:
        return .none
      case .binding:
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
          Color.green
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

          VStack(alignment: .center, spacing: 0) {
            GodTextField(
              text: viewStore.$firstName,
              fieldName: "First Name"
            )

            separator

            GodTextField(
              text: viewStore.$lastName,
              fieldName: "Last Name"
            )

            separator

            GodTextField(
              text: viewStore.$username,
              fieldName: "username"
            )

            separator

            Button(action: {}, label: {
              HStack(alignment: .center, spacing: 0) {
                Text("Gender")
                  .font(.body)
                  .foregroundColor(.godTextSecondaryLight)
                  .frame(width: 108, alignment: .leading)

                Text("Boy")
                  .multilineTextAlignment(.leading)
                  .frame(maxWidth: .infinity, alignment: .leading)
                  .font(.body)
                  .foregroundColor(.godBlack)

                Text(Image(systemName: "chevron.right"))
                  .font(.body)
                  .foregroundColor(.godTextSecondaryLight)
              }
              .padding(.horizontal, 12)
              .frame(maxWidth: .infinity)
              .frame(height: 52)
            })
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

                Text("Las Vegas Academy of Arts", bundle: .module)
                  .font(.body)
                  .foregroundColor(.godBlack)
                  .frame(maxWidth: .infinity, alignment: .leading)

                Text(Image(systemName: "chevron.right"))
                  .font(.body)
                  .foregroundColor(.godTextSecondaryLight)
              }
              .padding(.horizontal, 12)
              .frame(maxWidth: .infinity)
              .frame(height: 52)
              separator
              HStack(alignment: .center, spacing: 8) {
                Text(Image(systemName: "graduationcap.fill"))
                  .foregroundColor(.godTextSecondaryLight)
                  .font(.body)

                Text("9th Grade", bundle: .module)
                  .font(.body)
                  .foregroundColor(.godBlack)

                Spacer()

                Text("Class of 2026", bundle: .module)
                  .font(.caption)
                  .foregroundColor(.godTextSecondaryLight)

                Text(Image(systemName: "chevron.right"))
                  .font(.body)
                  .foregroundColor(.godTextSecondaryLight)
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

            Text("You are signed in as 19175926188", bundle: .module)
              .foregroundColor(.secondary)
              .font(.caption2)
          }
        }
        .padding(.all, 24)
      }
      .navigationTitle(Text("Edit Profile", bundle: .module))
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        if viewStore.state.isUserProfileChanges {
          ToolbarItem(placement: .navigationBarLeading) {
            Button("Cancel") {
              viewStore.send(.cancelEditButtonTapped)
            }
            .foregroundColor(.primary)
          }
          ToolbarItem(placement: .navigationBarTrailing) {
            Button("Save") {
              viewStore.send(.saveButtonTapped)
            }
            .foregroundColor(.primary)
          }
        } else {
          ToolbarItem(placement: .navigationBarLeading) {
            Button("Close") {
              viewStore.send(.closeButtonTapped)
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

  private var separator: some View {
    Color.godSeparator
      .frame(height: 1)
      .frame(maxWidth: .infinity)
  }

  private struct GodTextField: View {
    @Binding var text: String
    var fieldName: String

    var body: some View {
      HStack(alignment: .center, spacing: 0) {
        Text(fieldName)
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

struct ProfileEditViewPreviews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      ProfileEditView(
        store: .init(
          initialState: ProfileEditLogic.State(),
          reducer: { ProfileEditLogic() }
        )
      )
    }
  }
}
