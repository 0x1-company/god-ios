import ButtonStyles
import ComposableArchitecture
import Colors
import SwiftUI

public struct FullNameReducer: Reducer {
  public init() {}

  public struct State: Equatable {
    public init() {}
  }

  public enum Action: Equatable {
    case onTask
    case closeButtonTapped
  }
  
  @Dependency(\.dismiss) var dismiss

  public var body: some ReducerOf<Self> {
    Reduce { _, action in
      switch action {
      case .onTask:
        return .none

      case .closeButtonTapped:
        return .run { _ in
          await dismiss()
        }
      }
    }
  }
}

public struct FullNameView: View {
  let store: StoreOf<FullNameReducer>

  public init(store: StoreOf<FullNameReducer>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      VStack(spacing: 16) {
        Color.red
          .frame(width: 74, height: 74)
          .clipShape(Circle())
          .overlay(
            RoundedRectangle(cornerRadius: 74 / 2)
              .stroke(Color.white, lineWidth: 8)
          )

        Text("Tomoki Tsukiyama")
          .bold()

        Button {
          viewStore.send(.closeButtonTapped)
        } label: {
          Text("Close")
            .frame(height: 56)
            .frame(maxWidth: .infinity)
            .foregroundColor(.white)
            .background(Color.godService)
            .clipShape(Capsule())
            .padding(.horizontal, 16)
        }
        .buttonStyle(HoldDownButtonStyle())
      }
      .task { await viewStore.send(.onTask).finish() }
    }
  }
}

struct FullNameViewPreviews: PreviewProvider {
  static var previews: some View {
    FullNameView(
      store: .init(
        initialState: FullNameReducer.State(),
        reducer: { FullNameReducer() }
      )
    )
  }
}
