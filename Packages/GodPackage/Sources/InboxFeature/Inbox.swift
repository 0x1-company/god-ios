import ButtonStyles
import ColorHex
import ComposableArchitecture
import GodModeFeature
import LabeledButton
import SwiftUI

public struct InboxReducer: Reducer {
  public init() {}

  public struct State: Equatable {
    @PresentationState var godMode: GodModeReducer.State?

    public init() {}
  }

  public enum Action: Equatable {
    case onTask
    case seeWhoLikesYouButtonTapped
    case godMode(PresentationAction<GodModeReducer.Action>)
  }

  public var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .onTask:
        return .none

      case .seeWhoLikesYouButtonTapped:
        state.godMode = .init()
        return .none

      case .godMode:
        return .none
      }
    }
    .ifLet(\.$godMode, action: /Action.godMode) {
      GodModeReducer()
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
          ForEach(0 ..< 10) { _ in
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

          Button {
            viewStore.send(.seeWhoLikesYouButtonTapped)
          } label: {
            Label("See who likes you", systemImage: "lock.fill")
              .frame(height: 50)
              .frame(maxWidth: .infinity)
              .bold()
              .foregroundColor(.white)
              .background(Color.black)
              .clipShape(Capsule())
              .padding(.horizontal, 16)
              .padding(.top, 8)
          }
          .buttonStyle(HoldDownButtonStyle())
        }
        .ignoresSafeArea()
        .frame(height: 64)
      }
      .task { await viewStore.send(.onTask).finish() }
      .fullScreenCover(
        store: store.scope(
          state: \.$godMode,
          action: InboxReducer.Action.godMode
        ),
        content: GodModeView.init(store:)
      )
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
