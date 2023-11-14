import ComposableArchitecture
import God
import GodClient
import LabeledButton
import SwiftUI

@Reducer
public struct ManageAccountLogic {
  public init() {}

  public struct State: Equatable {
    @PresentationState var confirmationDialog: ConfirmationDialogState<Action.ConfirmationDialog>?
    public init() {}
  }

  public enum Action {
    case closeButtonTapped
    case resetBlockButtonTapped
    case resetHideButtonTapped
    case deleteButtonTapped
    case confirmationDialog(PresentationAction<ConfirmationDialog>)

    public enum ConfirmationDialog: Equatable {
      case confirm
    }
  }

  @Dependency(\.dismiss) var dismiss
  @Dependency(\.godClient) var godClient

  public var body: some Reducer<State, Action> {
    Reduce<State, Action> { state, action in
      switch action {
      case .closeButtonTapped:
        return .run { _ in
          await dismiss()
        }
      case .resetBlockButtonTapped:
        state.confirmationDialog = .resetBlock
        return .none

      case .resetHideButtonTapped:
        state.confirmationDialog = .resetBlock
        return .none

      case .deleteButtonTapped:
        return .none

      case .confirmationDialog(.presented(.confirm)):
        state.confirmationDialog = nil
        return .none

      case .confirmationDialog:
        return .none
      }
    }
  }
}

public struct ManageAccountView: View {
  let store: StoreOf<ManageAccountLogic>

  public init(store: StoreOf<ManageAccountLogic>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { _ in
      List {
        Section {
          Button {
            store.send(.resetBlockButtonTapped)
          } label: {
            Label("Reset Block List", systemImage: "eye.slash.fill")
          }
          Button {
            store.send(.resetHideButtonTapped)
          } label: {
            Label("Reset Hide List", systemImage: "eye.slash.fill")
          }
        } header: {
          Text("FRIENDS", bundle: .module)
        }

        Section {
          LabeledButton(
            String(localized: "Delete Account", bundle: .module),
            systemImage: "trash"
          ) {
            store.send(.deleteButtonTapped)
          }
          .foregroundStyle(.red)
        }
      }
      .navigationTitle(Text("Manage Account", bundle: .module))
      .navigationBarTitleDisplayMode(.inline)
      .confirmationDialog(store: store.scope(state: \.$confirmationDialog, action: { .confirmationDialog($0) }))
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button {
            store.send(.closeButtonTapped)
          } label: {
            Text("Close", bundle: .module)
              .foregroundStyle(.primary)
          }
        }
      }
    }
  }
}

#Preview {
  ManageAccountView(
    store: .init(
      initialState: ManageAccountLogic.State(),
      reducer: { ManageAccountLogic() }
    )
  )
}

extension ConfirmationDialogState where Action == ManageAccountLogic.Action.ConfirmationDialog {
  static let resetBlock = Self {
    TextState("Unblock all accounts", bundle: .module)
  } actions: {
    ButtonState(role: .destructive, action: .confirm) {
      TextState("Confirm", bundle: .module)
    }
  } message: {
    TextState("Are you sure you want to reset your block list?")
  }
}
