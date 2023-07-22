import ButtonStyles
import ComposableArchitecture
import LabeledButton
import SwiftUI
import ManageAccountFeature

public struct EditProfileReducer: ReducerProtocol {
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

  public var body: some ReducerProtocol<State, Action> {
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

public struct EditProfileView: View {
  let store: StoreOf<EditProfileReducer>

  public init(store: StoreOf<EditProfileReducer>) {
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
      .navigationTitle("EditProfile")
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
          action: EditProfileReducer.Action.manageAccount
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

struct EditProfileViewPreviews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      EditProfileView(
        store: .init(
          initialState: EditProfileReducer.State(),
          reducer: EditProfileReducer()
        )
      )
    }
  }
}
