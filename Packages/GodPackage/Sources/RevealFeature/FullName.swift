import ButtonStyles
import Colors
import ComposableArchitecture
import SwiftUI

public struct FullNameLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    let fulName: String

    public init(
      fulName: String
    ) {
      self.fulName = fulName
    }
  }

  public enum Action: Equatable {
    case onTask
    case closeButtonTapped
  }
  
  @Dependency(\.dismiss) var dismiss

  public var body: some Reducer<State, Action> {
    Reduce<State, Action> { _, action in
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
  let store: StoreOf<FullNameLogic>

  public init(store: StoreOf<FullNameLogic>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      VStack(spacing: 24) {
        Text(verbatim: viewStore.fulName)
          .bold()
          .font(.title2)

        Button {
          viewStore.send(.closeButtonTapped)
        } label: {
          Text("Close", bundle: .module)
            .frame(height: 56)
            .frame(maxWidth: .infinity)
            .foregroundColor(.white)
            .background(Color.godService)
            .clipShape(Capsule())
        }
        .padding(.horizontal, 16)
        .buttonStyle(HoldDownButtonStyle())
      }
      .task { await viewStore.send(.onTask).finish() }
    }
  }
}

#Preview {
  FullNameView(
    store: .init(
      initialState: FullNameLogic.State(
        fulName: "Tomoki Tsukiyama"
      ),
      reducer: { FullNameLogic() }
    )
  )
}
