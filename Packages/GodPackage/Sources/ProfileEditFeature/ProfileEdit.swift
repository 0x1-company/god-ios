import ButtonStyles
import ComposableArchitecture
import LabeledButton
import ManageAccountFeature
import SwiftUI
import FirebaseAuthClient

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
  @Dependency(\.firebaseAuth) var firebaseAuth

  public var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .restorePurchasesButtonTapped:
        return .none

      case .manageAccountButtonTapped:
        state.manageAccount = .init()
        return .none

      case .logoutButtonTapped:
        return .run { _ in
          try firebaseAuth.signOut()
        } catch: { error, send in
          print(error)
        }

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

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      ScrollView(.vertical) {
        VStack(spacing: 24) {
          Color.green
            .frame(width: 145, height: 145)
            .clipShape(Circle())

          VStack(spacing: 8) {
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
