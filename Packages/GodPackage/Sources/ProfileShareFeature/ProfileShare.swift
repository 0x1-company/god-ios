import ComposableArchitecture
import SwiftUI

public struct ProfileShareLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    var shareContents = [
      "Snapshot",
      "Instagram",
      "Messages",
      "Copy Link",
    ]
    public init() {}
  }

  public enum Action: Equatable {
    case onTask
    case closeButtonTapped
  }

  @Dependency(\.dismiss) var dismiss

  public var body: some Reducer<State, Action> {
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

public struct ProfileShareView: View {
  let store: StoreOf<ProfileShareLogic>

  public init(store: StoreOf<ProfileShareLogic>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      VStack(alignment: .center, spacing: 24) {
        Text("Share Profile")
          .bold()

        HStack(spacing: 12) {
          ForEach(viewStore.shareContents, id: \.self) { content in
            Button(action: {}) {
              VStack(spacing: 12) {
                Color.red
                  .clipShape(Circle())

                Text(content)
                  .foregroundColor(.black)
              }
            }
          }
        }

        Button {
          viewStore.send(.closeButtonTapped)
        } label: {
          Text("Close")
            .bold()
            .frame(height: 52)
            .frame(maxWidth: .infinity)
            .foregroundColor(.black)
        }
        .overlay(
          RoundedRectangle(cornerRadius: 52 / 2)
            .stroke(Color.primary, lineWidth: 1)
        )
      }
      .padding(.top, 16)
      .padding(.horizontal, 16)
      .task { await viewStore.send(.onTask).finish() }
    }
  }
}

struct ProfileShareViewPreviews: PreviewProvider {
  static var previews: some View {
    Text("ProfileShare")
      .sheet(
        isPresented: .constant(true)
      ) {
        ProfileShareView(
          store: .init(
            initialState: ProfileShareLogic.State(),
            reducer: { ProfileShareLogic() }
          )
        )
        .presentationDetents([.fraction(0.3)])
        .presentationDragIndicator(.visible)
      }
  }
}
