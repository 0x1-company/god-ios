import ComposableArchitecture
import SwiftUI

public struct GenderHelpReducer: Reducer {
  public init() {}

  public struct State: Equatable {
    public init() {}
  }

  public enum Action: Equatable {
    case onTask
    case okayButtonTapped
    case preferNotSayButtonTapped
  }

  @Dependency(\.dismiss) var dismiss

  public var body: some ReducerOf<Self> {
    Reduce { _, action in
      switch action {
      case .onTask:
        return .none

      case .okayButtonTapped:
        return .run { _ in
          await dismiss()
        }

      case .preferNotSayButtonTapped:
        return .run { _ in
          await dismiss()
        }
      }
    }
  }
}

public struct GenderHelpView: View {
  let store: StoreOf<GenderHelpReducer>

  public init(store: StoreOf<GenderHelpReducer>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      VStack(spacing: 12) {
        Image("restroom", bundle: .module)
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 64, height: 64)
          .cornerRadius(12)

        Text("Adding your gender helps create your polls")
        Text("See who likes you on God")

        Button {
          viewStore.send(.okayButtonTapped)
        } label: {
          Text("OK")
            .frame(height: 56)
            .frame(maxWidth: .infinity)
        }
        .foregroundColor(.white)
        .background(Color.orange)
        .clipShape(Capsule())

        Button("Prefer not to say") {
          viewStore.send(.preferNotSayButtonTapped)
        }
        .foregroundColor(.secondary)
      }
      .padding(.horizontal, 24)
    }
  }
}

struct GenderHelpViewPreviews: PreviewProvider {
  static var previews: some View {
    GenderHelpView(
      store: .init(
        initialState: GenderHelpReducer.State(),
        reducer: { GenderHelpReducer() }
      )
    )
  }
}
