import ComposableArchitecture
import SwiftUI
import God
import GodClient
import PlayAgainFeature
import CashOutFeature
import PollFeature

public struct GodLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    var child = Child.State.loading()
    public init() {}
  }

  public enum Action: Equatable {
    case onTask
    case presentPoll
    case child(Child.Action)
  }
  
  @Dependency(\.mainQueue) var mainQueue

  public var body: some Reducer<State, Action> {
    Reduce<State, Action> { state, action in
      switch action {
      case .onTask:
        return .run { send in
          try await mainQueue.sleep(for: .seconds(5))
          await send(.presentPoll)
        }
        
      case .presentPoll:
        state.child = .poll(
          .init()
        )
        return .none

      case .child:
        return .none
      }
    }
  }
  
  public struct Child: Reducer {
    public enum State: Equatable {
      case poll(PollLogic.State)
      case cashOut(CashOutLogic.State)
      case playAgain(PlayAgainLogic.State)
      case loading(GodLoadingLogic.State = .init())
    }
    public enum Action: Equatable {
      case poll(PollLogic.Action)
      case cashOut(CashOutLogic.Action)
      case playAgain(PlayAgainLogic.Action)
      case loading(GodLoadingLogic.Action)
    }
    public var body: some Reducer<State, Action> {
      Scope(state: /State.poll, action: /Action.poll) {
        PollLogic()
      }
      Scope(state: /State.cashOut, action: /Action.cashOut) {
        CashOutLogic()
      }
      Scope(state: /State.playAgain, action: /Action.playAgain) {
        PlayAgainLogic()
      }
      Scope(state: /State.loading, action: /Action.loading) {
        GodLoadingLogic()
      }
    }
  }
}

public struct GodView: View {
  let store: StoreOf<GodLogic>

  public init(store: StoreOf<GodLogic>) {
    self.store = store
  }

  public var body: some View {
    SwitchStore(store.scope(state: \.child, action: GodLogic.Action.child)) { initialState in
      switch initialState {
      case .poll:
        CaseLet(
          /GodLogic.Child.State.poll,
           action: GodLogic.Child.Action.poll,
           then: PollView.init(store:)
        )
      case .cashOut:
        CaseLet(
          /GodLogic.Child.State.cashOut,
           action: GodLogic.Child.Action.cashOut,
           then: CashOutView.init(store:)
        )
      case .playAgain:
        CaseLet(
          /GodLogic.Child.State.playAgain,
           action: GodLogic.Child.Action.playAgain,
           then: PlayAgainView.init(store:)
        )
      case .loading:
        CaseLet(
          /GodLogic.Child.State.loading,
           action: GodLogic.Child.Action.loading,
           then: GodLoadingView.init(store:)
        )
      }
    }
    .task { await store.send(.onTask).finish() }
  }
}

struct GodViewPreviews: PreviewProvider {
  static var previews: some View {
    GodView(
      store: .init(
        initialState: GodLogic.State(),
        reducer: { GodLogic() }
      )
    )
  }
}
