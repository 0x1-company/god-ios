import ComposableArchitecture
import SwiftUI

public struct ManageAccountLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    public init() {}
  }

  public enum Action: Equatable {
    case closeButtonTapped
  }

  @Dependency(\.dismiss) var dismiss

  public var body: some Reducer<State, Action> {
    Reduce<State, Action> { _, action in
      switch action {
      case .closeButtonTapped:
        return .run { _ in
          await dismiss()
        }
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
    WithViewStore(store, observe: { $0 }) { viewStore in
      List {
        Section("Settings") {
          LabeledContent {
            Toggle("Reduce Notifications", isOn: .constant(true))
          } label: {
            Image(systemName: "eye.slash.fill")
          }

          LabeledContent {
            Toggle("Hide Top Flames", isOn: .constant(true))
          } label: {
            Image(systemName: "eye.slash.fill")
          }

          LabeledContent {
            Toggle("Take a Break from Gas", isOn: .constant(true))
          } label: {
            Image(systemName: "eye.slash.fill")
          }
        }

        Section("add friends") {
          Label("Reset Block List", systemImage: "eye.slash.fill")
          Label("Reset Hide List", systemImage: "eye.slash.fill")
        }

        Section {
          Button(action: {}) {
            Label("Delete Account", systemImage: "trash")
          }
          .foregroundColor(.red)
        }
      }
      .navigationTitle(Text("Manage Account", bundle: .module))
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button("Close") {
            viewStore.send(.closeButtonTapped)
          }
          .foregroundColor(.primary)
        }
      }
    }
  }
}

struct ManageAccountViewPreviews: PreviewProvider {
  static var previews: some View {
    ManageAccountView(
      store: .init(
        initialState: ManageAccountLogic.State(),
        reducer: { ManageAccountLogic() }
      )
    )
  }
}
