import ComposableArchitecture
import SwiftUI

public struct DoubleCheckNameReducer: ReducerProtocol {
  public init() {}

  public struct State: Equatable {
    @PresentationState var alert: AlertState<Action.Alert>?
    public init() {}
  }

  public enum Action: Equatable {
    case infoButtonTapped
    case alert(PresentationAction<Alert>)
    
    public enum Alert: Equatable {
      case confirmContinueAnyway
      case confirmOkay
    }
  }

  public var body: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      switch action {
      case .infoButtonTapped:
        state.alert = AlertState {
          TextState("Double check your name")
        } actions: {
          ButtonState(action: .confirmContinueAnyway) {
            TextState("Continue Anyway")
          }
          ButtonState(action: .confirmOkay) {
            TextState("OK")
          }
        } message: {
          TextState("Your friends may see you as the name in their contacts")
        }
        return .none
        
      case .alert:
        return .none
      }
    }
  }
}

public struct DoubleCheckNameView: View {
  let store: StoreOf<DoubleCheckNameReducer>

  public init(store: StoreOf<DoubleCheckNameReducer>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      Button {
        viewStore.send(.infoButtonTapped)
      } label: {
        Image(systemName: "info.circle.fill")
          .foregroundColor(.white)
      }
      .alert(
        store: store.scope(
          state: \.$alert,
          action: { .alert($0) }
        )
      )
    }
  }
}

struct DoubleCheckNameViewPreviews: PreviewProvider {
  static var previews: some View {
    DoubleCheckNameView(
      store: .init(
        initialState: DoubleCheckNameReducer.State(),
        reducer: DoubleCheckNameReducer()
      )
    )
  }
}
