import Colors
import ComposableArchitecture
import SwiftUI

public struct SchoolHelpSheetReducer: Reducer {
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
          await self.dismiss()
        }
      }
    }
  }
}

public struct SchoolHelpSheetView: View {
  let store: StoreOf<SchoolHelpSheetReducer>

  public init(store: StoreOf<SchoolHelpSheetReducer>) {
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
        }
        .foregroundColor(.white)
        .background(Color.god.service)
        .clipShape(Capsule())
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
        initialState: SchoolHelpSheetReducer.State(),
        reducer: { SchoolHelpSheetReducer() }
      )
    )
  }
}
