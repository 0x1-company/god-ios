import CashOutFeature
import ComposableArchitecture
import God
import GodClient
import PlayAgainFeature
import PollFeature
import SwiftUI

public struct GodLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    var child = Child.State.loading()
    public init() {}
  }

  public enum Action: Equatable {
    case onTask
    case currentPollResponse(TaskResult<God.CurrentPollQuery.Data>)
    case child(Child.Action)
  }

  @Dependency(\.mainQueue) var mainQueue
  @Dependency(\.godClient) var godClient
  
  enum Cancel {
    case currentPoll
  }

  public var body: some Reducer<State, Action> {
    Reduce<State, Action> { state, action in
      switch action {
      case .onTask:
        return .run { send in
          await currentPollRequest(send: send)
        }
        .cancellable(id: Cancel.currentPoll, cancelInFlight: true)

      case let .currentPollResponse(.success(data)) where data.currentPoll.status == .coolDown:
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        guard
          let coolDown = data.currentPoll.coolDown,
          let until = dateFormatter.date(from: coolDown.until) else {
          return .none
        }
        state.child = .playAgain(.init(until: until))
        return .none
        
      case let .currentPollResponse(.success(data)) where data.currentPoll.status == .active:
        guard let poll = data.currentPoll.poll else { return .none }
        state.child = .poll(.init(poll: poll))
        return .none

      case .currentPollResponse(.success):
        return .none
        
      case .currentPollResponse(.failure):
        return .none

      case .child:
        return .none
      }
    }
  }
  
  func currentPollRequest(send: Send<Action>) async {
    do {
      for try await data in godClient.currentPoll() {
        await send(.currentPollResponse(.success(data)))
      }
    } catch {
      await send(.currentPollResponse(.failure(error)))
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
