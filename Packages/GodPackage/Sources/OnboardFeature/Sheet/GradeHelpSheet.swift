import ButtonStyles
import Colors
import ComposableArchitecture
import SwiftUI

public struct GradeHelpSheetReducer: Reducer {
  public init() {}

  public struct State: Equatable {
    public init() {}
  }

  public enum Action: Equatable {
    case onTask
    case okayButtonTapped
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
      }
    }
  }
}

public struct GradeHelpSheetView: View {
  let store: StoreOf<GradeHelpSheetReducer>

  public init(store: StoreOf<GradeHelpSheetReducer>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      VStack(spacing: 12) {
        Image("school", bundle: .module)
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 64, height: 64)
          .cornerRadius(12)

        Text("Your grade helps you\nfind a school to join")
          .bold()

        Text("We will show schools on\nthe next page")

        Button {
          viewStore.send(.okayButtonTapped)
        } label: {
          Text("OK")
            .frame(height: 56)
            .frame(maxWidth: .infinity)
            .foregroundColor(.white)
            .background(Color.godService)
            .clipShape(Capsule())
        }
        .buttonStyle(HoldDownButtonStyle())
      }
      .padding(.horizontal, 24)
      .multilineTextAlignment(.center)
    }
  }
}

struct GradeHelpSheetViewPreviews: PreviewProvider {
  static var previews: some View {
    GradeHelpSheetView(
      store: .init(
        initialState: GradeHelpSheetReducer.State(),
        reducer: { GradeHelpSheetReducer() }
      )
    )
  }
}
