import ColorHex
import ComposableArchitecture
import LabeledButton
import SwiftUI

public struct InboxReducer: Reducer {
  public init() {}

  public struct State: Equatable {
    public init() {}
  }

  public enum Action: Equatable {
    case onTask
  }

  public var body: some Reducer<State, Action> {
    Reduce { _, action in
      switch action {
      case .onTask:
        return .none
      }
    }
  }
}

public struct InboxView: View {
  let store: StoreOf<InboxReducer>

  public init(store: StoreOf<InboxReducer>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      ZStack(alignment: .bottom) {
        List {
          ForEach(0 ..< 100) { _ in
            HStack(spacing: 0) {
              LabeledContent {
                Text("16h")
              } label: {
                Label {
                  Text("From a boy")
                } icon: {
                  Image(systemName: "flame.fill")
                    .font(.largeTitle)
                }
              }
              .padding(.horizontal, 16)
            }
            .listRowSeparator(.hidden)
            .frame(height: 72)
            .background(
              Color.white
            )
            .cornerRadius(8)
            .compositingGroup()
            .shadow(color: Color.black.opacity(0.1), radius: 10)
          }
        }
        .listStyle(.plain)
        .background(Color(0xFFFA_FAFA))

        ZStack(alignment: .top) {
          Color.white.blur(radius: 1.0)

          LabeledButton("See who likes you", systemImage: "lock.fill", action: {})
            .bold()
            .foregroundColor(.white)
            .background(Color.black)
            .clipShape(Capsule())
            .padding(.horizontal, 16)
            .padding(.top, 8)
        }
        .ignoresSafeArea()
        .frame(height: 64)
      }
      .task { await viewStore.send(.onTask).finish() }
    }
  }
}

struct InboxViewPreviews: PreviewProvider {
  static var previews: some View {
    InboxView(
      store: .init(
        initialState: InboxReducer.State(),
        reducer: { InboxReducer() }
      )
    )
  }
}
