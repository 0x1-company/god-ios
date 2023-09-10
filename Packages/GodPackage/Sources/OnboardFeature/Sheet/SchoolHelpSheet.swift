import ButtonStyles
import Colors
import ComposableArchitecture
import SwiftUI

public struct SchoolHelpSheetLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    public init() {}
  }

  public enum Action: Equatable {
    case onTask
    case okayButtonTapped
  }

  @Dependency(\.dismiss) var dismiss

  public var body: some Reducer<State, Action> {
    Reduce<State, Action> { _, action in
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

public struct SchoolHelpSheetView: View {
  let store: StoreOf<SchoolHelpSheetLogic>

  public init(store: StoreOf<SchoolHelpSheetLogic>) {
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

        Text("Adding your school lets you\nadd classmates on God")
          .bold()

        Text("Choose the right school so\nyou can find your friends")

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

struct SchoolHelpSheetViewPreviews: PreviewProvider {
  static var previews: some View {
    SchoolHelpSheetView(
      store: .init(
        initialState: SchoolHelpSheetLogic.State(),
        reducer: { SchoolHelpSheetLogic() }
      )
    )
  }
}
