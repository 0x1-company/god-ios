import ComposableArchitecture
import SwiftUI

public struct FromSchoolReducer: Reducer {
  public init() {}

  public struct State: Equatable {
    @BindingState var searchable = ""
    public init() {}
  }

  public enum Action: Equatable, BindableAction {
    case onTask
    case closeButtonTapped
    case binding(BindingAction<State>)
  }

  @Dependency(\.dismiss) var dismiss

  public var body: some Reducer<State, Action> {
    BindingReducer()
    Reduce { _, action in
      switch action {
      case .onTask:
        return .none

      case .closeButtonTapped:
        return .run { _ in
          await dismiss()
        }

      case .binding:
        return .none
      }
    }
  }
}

public struct FromSchoolView: View {
  let store: StoreOf<FromSchoolReducer>

  public init(store: StoreOf<FromSchoolReducer>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      List(0 ..< 100) { _ in
        FriendAddCard()
      }
      .listStyle(.plain)
      .navigationTitle("Friends of Friends")
      .navigationBarTitleDisplayMode(.inline)
      .task { await viewStore.send(.onTask).finish() }
      .searchable(text: viewStore.$searchable)
      .toolbar {
        Button {
          viewStore.send(.closeButtonTapped)
        } label: {
          Image(systemName: "xmark")
            .foregroundColor(.secondary)
        }
      }
    }
  }
}

struct FromSchoolViewPreviews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      FromSchoolView(
        store: .init(
          initialState: FromSchoolReducer.State(),
          reducer: { FromSchoolReducer() }
        )
      )
    }
  }
}
