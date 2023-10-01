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
    Scope(state: \.child, action: /Action.child, child: Child.init)
    Reduce<State, Action> { state, action in
      switch action {
      case .onTask:
        return .run { send in
          try await mainQueue.sleep(for: .seconds(1))
          await currentPollRequest(send: send)
        }
        .cancellable(id: Cancel.currentPoll, cancelInFlight: true)

      case let .currentPollResponse(.success(data)) where data.currentPoll.status == .coolDown:
        guard
          let coolDown = data.currentPoll.coolDown,
          let untilTimeInterval = TimeInterval(coolDown.until)
        else {
          return .none
        }
        let until = Date(timeIntervalSince1970: untilTimeInterval / 1000.0)
        updateChild(state: &state, child: .playAgain(.init(until: until)))
        return .none

      case let .currentPollResponse(.success(data)) where data.currentPoll.status == .active:
        guard let poll = data.currentPoll.poll else { return .none }
        let pollQuestions = poll.pollQuestions
          .filter { $0.choiceGroups.filter { $0.choices.count >= 4 }.count >= 1 }
        if pollQuestions.count >= 12 {
          updateChild(state: &state, child: .poll(.init(poll: poll)))
        } else {
          updateChild(state: &state, child: .share())
        }
        return .none

      case .currentPollResponse(.success):
        return .none

      case .currentPollResponse(.failure):
        return .none

      case let .child(.poll(.delegate(.finish(earnedCoinAmount)))):
        updateChild(state: &state, child: .cashOut(.init(earnedCoinAmount: earnedCoinAmount)))
        return .none

      case .child(.cashOut(.delegate(.finish))):
        return .run { send in
          await currentPollRequest(send: send)
        }
        .cancellable(id: Cancel.currentPoll, cancelInFlight: true)

      case .child:
        return .none
      }
    }
  }

  func updateChild(state: inout State, child: Child.State) {
    switch (state.child, child) {
    case (.loading, .loading):
      break
    case (.poll, .poll):
      break
    case (.cashOut, .cashOut):
      break
    case (.playAgain, .playAgain):
      break
    default:
      state.child = child
    }
    state.child = .loading(.init())
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
      case share(ShareTheAppLogic.State = .init())
      case loading(GodLoadingLogic.State = .init())
    }

    public enum Action: Equatable {
      case poll(PollLogic.Action)
      case cashOut(CashOutLogic.Action)
      case playAgain(PlayAgainLogic.Action)
      case share(ShareTheAppLogic.Action)
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
      Scope(state: /State.share, action: /Action.share) {
        ShareTheAppLogic()
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
      case .share:
        CaseLet(
          /GodLogic.Child.State.share,
          action: GodLogic.Child.Action.share,
          then: ShareTheAppView.init(store:)
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
