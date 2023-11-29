import CashOutFeature
import ComposableArchitecture
import God
import GodClient
import PlayAgainFeature
import PollFeature
import SwiftUI
import UserNotificationClient

@Reducer
public struct GodLogic {
  public init() {}

  @Reducer
  public struct Child {
    public enum State: Equatable {
      case poll(PollLogic.State)
      case cashOut(CashOutLogic.State)
      case playAgain(PlayAgainLogic.State)
      case share(ShareTheAppLogic.State = .init())
      case loading(GodLoadingLogic.State = .init())
    }

    public enum Action {
      case poll(PollLogic.Action)
      case cashOut(CashOutLogic.Action)
      case playAgain(PlayAgainLogic.Action)
      case share(ShareTheAppLogic.Action)
      case loading(GodLoadingLogic.Action)
    }

    public var body: some Reducer<State, Action> {
      Scope(state: \.poll, action: \.poll, child: PollLogic.init)
      Scope(state: \.cashOut, action: \.cashOut, child: CashOutLogic.init)
      Scope(state: \.playAgain, action: \.playAgain, child: PlayAgainLogic.init)
      Scope(state: \.share, action: \.share, child: ShareTheAppLogic.init)
      Scope(state: \.loading, action: \.loading, child: GodLoadingLogic.init)
    }
  }

  public struct State: Equatable {
    var child = Child.State.loading()
    public init() {}
  }

  public enum Action {
    case onTask
    case currentPollResponse(TaskResult<God.CurrentPollQuery.Data>)
    case child(Child.Action)
  }

  @Dependency(\.mainQueue) var mainQueue
  @Dependency(\.godClient) var godClient
  @Dependency(\.userNotifications) var userNotifications
  @Dependency(\.calendar) var calendar

  enum Cancel {
    case currentPoll
  }

  public var body: some Reducer<State, Action> {
    Scope(state: \.child, action: \.child, child: Child.init)
    Reduce<State, Action> { state, action in
      switch action {
      case .onTask:
        return .run { send in
          await currentPollRequest(send: send)
        }

      case let .currentPollResponse(.success(data)) where data.currentPoll.status == .coolDown:
        guard
          let coolDown = data.currentPoll.coolDown,
          let untilTimeInterval = TimeInterval(coolDown.until)
        else {
          return .none
        }
        let until = Date(timeIntervalSince1970: untilTimeInterval / 1000.0)
        updateChild(state: &state, child: .playAgain(.init(until: until)))
        return .run { _ in
          await registerNewPollsAvailable(until: until)
        }

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

      case .child(.poll(.delegate(.voted))):
        return .run { _ in
          await registerPollsAwaitYourInput()
        }

      case let .child(.poll(.delegate(.finish(earnedCoinAmount)))):
        updateChild(state: &state, child: .cashOut(.init(earnedCoinAmount: earnedCoinAmount)))
        return .run { _ in
          await userNotifications.removePendingNotificationRequestsWithIdentifiers(["polls-await-your-input"])
        }

      case .child(.cashOut(.delegate(.finish))):
        return .run { send in
          await currentPollRequest(send: send)
        }

      case .child(.playAgain(.delegate(.loading))):
        updateChild(state: &state, child: .loading())
        return .run { send in
          await currentPollRequest(send: send)
        }
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
  }

  func currentPollRequest(send: Send<Action>) async {
    await withTaskCancellation(id: Cancel.currentPoll, cancelInFlight: true) {
      do {
        for try await data in godClient.currentPoll() {
          await send(.currentPollResponse(.success(data)))
        }
      } catch {
        await send(.currentPollResponse(.failure(error)))
      }
    }
  }

  func registerNewPollsAvailable(until: Date) async {
    let content = UNMutableNotificationContent()
    content.title = String(localized: "New polls available", bundle: .module)
    content.body = String(localized: "🏆 Tap to vote", bundle: .module)
    content.sound = UNNotificationSound.default

    let trigger = UNCalendarNotificationTrigger(
      dateMatching: calendar.dateComponents(
        [.year, .month, .day, .hour, .minute, .second],
        from: until
      ),
      repeats: false
    )
    let request = UNNotificationRequest(
      identifier: "new-polls-available",
      content: content,
      trigger: trigger
    )
    do {
      try await userNotifications.add(request)
    } catch {
      print("\(#function): \(error)")
    }
  }

  func registerPollsAwaitYourInput() async {
    let content = UNMutableNotificationContent()
    content.title = String(localized: "Polls await your input", bundle: .module)
    content.body = String(localized: "🏆 Take the 12-polls challenge and earn some coins", bundle: .module)
    content.sound = UNNotificationSound.default

    let trigger = UNTimeIntervalNotificationTrigger(
      timeInterval: 60 * 3,
      repeats: false
    )
    let request = UNNotificationRequest(
      identifier: "polls-await-your-input",
      content: content,
      trigger: trigger
    )
    do {
      try await userNotifications.add(request)
    } catch {
      print("\(#function): \(error)")
    }
  }
}

public struct GodView: View {
  let store: StoreOf<GodLogic>

  public init(store: StoreOf<GodLogic>) {
    self.store = store
  }

  public var body: some View {
    SwitchStore(store.scope(state: \.child, action: \.child)) { initialState in
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

#Preview {
  GodView(
    store: .init(
      initialState: GodLogic.State(),
      reducer: { GodLogic() }
    )
  )
}
