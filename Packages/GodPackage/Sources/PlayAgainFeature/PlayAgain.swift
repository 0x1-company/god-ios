import AnalyticsClient
import ComposableArchitecture
import God
import GodClient
import ShareLinkBuilder
import StoreKit
import Styleguide
import SwiftUI

public struct PlayAgainLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    var until: Date

    var countdown = "00:00"
    var currentUser: God.CurrentUserQuery.Data.CurrentUser?

    public init(until: Date) {
      self.until = until
    }
  }

  public enum Action: Equatable {
    case onTask
    case onAppear
    case timerTick
    case inviteFriendButtonTapped
    case currentUserResponse(TaskResult<God.CurrentUserQuery.Data>)
    case delegate(Delegate)
    
    public enum Delegate: Equatable {
      case loading
    }
  }

  @Dependency(\.date.now) var now
  @Dependency(\.openURL) var openURL
  @Dependency(\.calendar) var calendar
  @Dependency(\.godClient) var godClient
  @Dependency(\.analytics) var analytics
  @Dependency(\.continuousClock) var clock
  
  enum Cancel {
    case timer
  }

  public var body: some Reducer<State, Action> {
    Reduce<State, Action> { state, action in
      switch action {
      case .onTask:
        return .run { send in
          await withTaskGroup(of: Void.self) { group in
            group.addTask {
              await send(.timerTick, animation: .default)
            }
            group.addTask {
              await withTaskCancellation(id: Cancel.timer, cancelInFlight: true) {
                await startTimer(send: send)
              }
            }
            group.addTask {
              do {
                for try await data in godClient.currentUser() {
                  await send(.currentUserResponse(.success(data)))
                }
              } catch {
                await send(.currentUserResponse(.failure(error)))
              }
            }
          }
        }
      case .onAppear:
        analytics.logScreen(screenName: "PlayAgain", of: self)
        return .none

      case .timerTick where state.until < now:
        return .run { send in
          Task.cancel(id: Cancel.timer)
          await send(.delegate(.loading), animation: .default)
        }

      case .timerTick:
        let difference = calendar.dateComponents([.minute, .second], from: now, to: state.until)
        let minute = String(format: "%02d", difference.minute ?? 0)
        let second = String(format: "%02d", difference.second ?? 0)
        state.countdown = minute + ":" + second
        return .none

      case .inviteFriendButtonTapped:
        guard let url = ShareLinkBuilder.buildForLine(path: .invite, username: state.currentUser?.username)
        else { return .none }

        analytics.buttonClick(
          name: .inviteFriend,
          parameters: [
            "title": String(localized: "Invite a friend", bundle: .module),
            "url": url,
          ]
        )
        return .run { _ in
          await openURL(url)
        }

      case let .currentUserResponse(.success(data)):
        state.currentUser = data.currentUser
        return .none

      case .currentUserResponse(.failure):
        state.currentUser = nil
        return .none
        
      case .delegate:
        return .none
      }
    }
  }

  private func startTimer(send: Send<Action>) async {
    for await _ in clock.timer(interval: .seconds(1)) {
      await send(.timerTick, animation: .default)
    }
  }
}

public struct PlayAgainView: View {
  @Environment(\.requestReview) var requestReview

  let store: StoreOf<PlayAgainLogic>

  public init(store: StoreOf<PlayAgainLogic>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      VStack(spacing: 44) {
        Text("Play Again", bundle: .module)
          .font(.system(.largeTitle, design: .rounded, weight: .black))

        Image(.locked)
          .rotationEffect(Angle(degrees: -10.0))

        Text("New Polls in \(viewStore.countdown)", bundle: .module)
          .font(.system(.body, design: .rounded, weight: .bold))

        Text("OR", bundle: .module)
          .foregroundColor(.secondary)
          .font(.system(.body, design: .rounded))

        Text("Skip the wait", bundle: .module)
          .multilineTextAlignment(.center)
          .foregroundColor(.secondary)
          .font(.system(.body, design: .rounded))

        Button {
          viewStore.send(.inviteFriendButtonTapped)
        } label: {
          Text("Invite a friend", bundle: .module)
            .frame(height: 54)
            .frame(maxWidth: .infinity)
            .foregroundColor(Color.black)
            .font(.system(.body, design: .rounded, weight: .bold))
            .overlay(alignment: .leading) {
              Image(.line)
                .resizable()
                .aspectRatio(1, contentMode: .fit)
                .frame(width: 32, height: 32)
                .clipped()
            }
            .padding(.horizontal, 16)
            .background(Color.white)
            .clipShape(Capsule())
            .shadow(color: .black.opacity(0.2), radius: 25)
        }
        .padding(.horizontal, 65)
        .buttonStyle(HoldDownButtonStyle())
      }
      .onAppear { store.send(.onAppear) }
      .task {
        requestReview()
        await viewStore.send(.onTask).finish()
      }
    }
  }
}

#Preview {
  PlayAgainView(
    store: .init(
      initialState: PlayAgainLogic.State(
        until: Date.now.addingTimeInterval(3600)
      ),
      reducer: { PlayAgainLogic() }
    )
  )
  .environment(\.locale, Locale(identifier: "ja-JP"))
}
