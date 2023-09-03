import AnimationDisableTransaction
import ButtonStyles
import Colors
import ComposableArchitecture
import SwiftUI

public struct ActivityDetailReducer: Reducer {
  public init() {}

  public struct State: Equatable {
    @PresentationState var destination: Destination.State?
    public init() {}
  }

  public enum Action: Equatable {
    case onTask
    case seeWhoSentItButtonTapped
    case closeButtonTapped
    case destination(PresentationAction<Destination.Action>)
  }

  @Dependency(\.dismiss) var dismiss

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .onTask:
        return .none

      case .seeWhoSentItButtonTapped:
        state.destination = .reveal()
        return .none

      case .closeButtonTapped:
        return .run { _ in
          await dismiss()
        }
      case .destination(.dismiss):
        state.destination = nil
        return .none
      case .destination:
        return .none
      }
    }
  }
  
  public struct Destination: Reducer {
    public enum State: Equatable {
      case reveal(RevealReducer.State = .init())
    }
    public enum Action: Equatable {
      case reveal(RevealReducer.Action)
    }
    public var body: some Reducer<State, Action> {
      Scope(state: /State.reveal, action: /Action.reveal, child: RevealReducer.init)
    }
  }
}

public struct ActivityDetailView: View {
  let store: StoreOf<ActivityDetailReducer>

  public init(store: StoreOf<ActivityDetailReducer>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      VStack {
        VStack(spacing: 50) {
          Spacer()

          VStack(spacing: 20) {
            Image("other", bundle: .module)
              .resizable()
              .frame(width: 80, height: 80)

            Text("From someone\nin 11th grade")
          }

          VStack(spacing: 20) {
            Text("Double texts with no shame")
              .bold()

            Text("godapp.jp")
              .bold()
          }
          Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.godPurple)
        .foregroundColor(.godWhite)
        .multilineTextAlignment(.center)
        .onTapGesture {
          viewStore.send(.closeButtonTapped, transaction: .animationDisable)
        }

        Button {
          viewStore.send(.seeWhoSentItButtonTapped)
        } label: {
          Label("See who sent it", systemImage: "lock.fill")
            .frame(height: 50)
            .frame(maxWidth: .infinity)
            .bold()
            .foregroundColor(.white)
            .background(Color.godGray)
            .clipShape(Capsule())
            .padding(.horizontal, 16)
            .padding(.top, 8)
        }
        .buttonStyle(HoldDownButtonStyle())
      }
      .background(.black)
      .task { await viewStore.send(.onTask).finish() }
      .sheet(
        store: store.scope(state: \.$destination, action: { .destination($0) }),
        state: /ActivityDetailReducer.Destination.State.reveal,
        action: ActivityDetailReducer.Destination.Action.reveal,
        content: { store in
          RevealView(store: store)
            .presentationDetents([.fraction(0.4)])
        }
      )
    }
  }
}

struct ActivityDetailViewPreviews: PreviewProvider {
  static var previews: some View {
    ActivityDetailView(
      store: .init(
        initialState: ActivityDetailReducer.State(),
        reducer: { ActivityDetailReducer() }
      )
    )
  }
}
