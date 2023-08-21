import ButtonStyles
import Colors
import ComposableArchitecture
import LabeledButton
import ManageAccountFeature
import SwiftUI

public struct ProfileEditReducer: Reducer {
  public init() {}

  public struct State: Equatable {
    @PresentationState var manageAccount: ManageAccountReducer.State?
    public init() {}
  }

  public enum Action: Equatable {
    case restorePurchasesButtonTapped
    case manageAccountButtonTapped
    case logoutButtonTapped
    case closeButtonTapped
    case manageAccount(PresentationAction<ManageAccountReducer.Action>)
  }

  @Dependency(\.dismiss) var dismiss

  public var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .restorePurchasesButtonTapped:
        return .none

      case .manageAccountButtonTapped:
        state.manageAccount = .init()
        return .none

      case .logoutButtonTapped:
        return .none

      case .closeButtonTapped:
        return .run { _ in
          await dismiss()
        }

      case .manageAccount:
        return .none
      }
    }
    .ifLet(\.$manageAccount, action: /Action.manageAccount) {
      ManageAccountReducer()
    }
  }
}

public struct ProfileEditView: View {
  let store: StoreOf<ProfileEditReducer>

  public init(store: StoreOf<ProfileEditReducer>) {
    self.store = store
  }

  @State private var firstName: String = "Tomoki"
  @State private var lastName: String = "Tsukiyama"
  @State private var username: String = "tomokisun"

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

          userSettingsSection

          VStack(alignment: .leading, spacing: 8) {
            Text("SCHOOL")
              .font(.caption)
              .bold()
              .foregroundColor(.godTextSecondaryLight)

            VStack(alignment: .center, spacing: 0) {
              HStack(alignment: .center, spacing: 8) {
                Text(Image(systemName: "house.fill"))
                  .foregroundColor(.godTextSecondaryLight)
                  .font(.body)

                Text("Las Vegas Academy of Arts")
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

                Text("9th Grade")
                  .font(.body)
                  .foregroundColor(.godBlack)

                Spacer()

                Text("Class of 2026")
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
            Text("ACCOUNT SETTING")
              .font(.caption)
              .bold()
              .foregroundColor(.godTextSecondaryLight)
            LabeledButton("Restore Purchases", systemImage: "clock.arrow.circlepath") {
              viewStore.send(.restorePurchasesButtonTapped)
            }

            LabeledButton("Manage Account", systemImage: "gearshape.fill") {
              viewStore.send(.manageAccountButtonTapped)
            }

            LabeledButton("Logout", systemImage: "rectangle.portrait.and.arrow.right") {
              viewStore.send(.logoutButtonTapped)
            }

            Text("You are signed in as 19175926188")
              .foregroundColor(.secondary)
              .font(.caption2)
          }
          .buttonStyle(CornerRadiusBorderButtonStyle())
        }
        .padding(.all, 24)
      }
      .navigationTitle("Edit Profile")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button("Close") {
            viewStore.send(.closeButtonTapped)
          }
          .foregroundColor(.primary)
        }
      }
      .sheet(
        store: store.scope(
          state: \.$manageAccount,
          action: ProfileEditReducer.Action.manageAccount
        ),
        content: { store in
          NavigationStack {
            ManageAccountView(store: store)
          }
        }
      )
    }
  }

  private var separator: some View {
    Color.godSeparator
      .frame(height: 1)
      .frame(maxWidth: .infinity)
  }

  private var userSettingsSection: some View {
    VStack(alignment: .center, spacing: 0) {
      HStack(alignment: .center, spacing: 0) {
        Text("First Name")
          .font(.body)
          .foregroundColor(.godTextSecondaryLight)
          .frame(width: 108, alignment: .leading)

        TextField("", text: $firstName)
          .multilineTextAlignment(.leading)
          .textFieldStyle(PlainTextFieldStyle())
          .font(.body)
          .foregroundColor(.godBlack)
      }
      .padding(.horizontal, 12)
      .frame(maxWidth: .infinity)
      .frame(height: 52)

      separator

      HStack(alignment: .center, spacing: 0) {
        Text("Last Name")
          .font(.body)
          .foregroundColor(.godTextSecondaryLight)
          .frame(width: 108, alignment: .leading)

        TextField("", text: $lastName)
          .multilineTextAlignment(.leading)
          .textFieldStyle(PlainTextFieldStyle())
          .font(.body)
          .foregroundColor(.godBlack)
      }
      .padding(.horizontal, 12)
      .frame(maxWidth: .infinity)
      .frame(height: 52)

      separator

      HStack(alignment: .center, spacing: 0) {
        Text("Username")
          .font(.body)
          .foregroundColor(.godTextSecondaryLight)
          .frame(width: 108, alignment: .leading)

        TextField("", text: $username)
          .multilineTextAlignment(.leading)
          .textFieldStyle(PlainTextFieldStyle())
          .font(.body)
          .foregroundColor(.godBlack)
      }
      .padding(.horizontal, 12)
      .frame(maxWidth: .infinity)
      .frame(height: 52)

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
  }
}

struct ProfileEditViewPreviews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      ProfileEditView(
        store: .init(
          initialState: ProfileEditReducer.State(),
          reducer: { ProfileEditReducer() }
        )
      )
    }
  }
}
