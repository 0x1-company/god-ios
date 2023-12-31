import ActivityView
import AnalyticsClient
import ComposableArchitecture
import God
import GodClient
import Lottie
import ShareLinkBuilder
import ShareLinkClient
import Styleguide
import SwiftUI

@Reducer
public struct InviteFriendLogic {
  public init() {}

  public struct CompletionWithItems: Equatable {
    public let activityType: UIActivity.ActivityType?
    public let result: Bool
  }

  @Reducer
  public struct Destination {
    @Reducer
    public struct Activity {
      public struct State: Equatable {
        public init() {}
      }

      public enum Action {}
      public var body: some ReducerOf<Self> {
        EmptyReducer()
      }
    }

    public enum State: Equatable {
      case activity(Activity.State = .init())
      case alert(AlertState<Action.Alert>)
    }

    public enum Action {
      case activity(Activity.Action)
      case alert(Alert)

      public enum Alert: Equatable {
        case confirmOkay
      }
    }

    public func reduce(into state: inout State, action: Action) -> Effect<Action> {
      .none
    }
  }

  public struct State: Equatable {
    var sharedText = ""
    var remainingInvitationCount: Int {
      invites.filter { !$0 }.count
    }

    var invites = Array(repeating: false, count: 5)
    var receivedActivity: ReceivedActivityLogic.State?
    @PresentationState var destination: Destination.State?

    public init() {}
  }

  public enum Action: BindableAction {
    case onTask
    case onAppear
    case whyFriendsButtonTapped
    case inviteFriendButtonTapped
    case currentUserResponse(TaskResult<God.CurrentUserQuery.Data>)
    case generateSharedTextResponse(Result<String, Error>)
    case onCompletion(CompletionWithItems)
    case binding(BindingAction<State>)
    case receivedActivity(ReceivedActivityLogic.Action)
    case destination(PresentationAction<Destination.Action>)
    case delegate(Delegate)

    public enum Delegate: Equatable {
      case nextScreen
    }
  }

  @Dependency(\.godClient) var godClient
  @Dependency(\.analytics) var analytics
  @Dependency(\.shareLink.generateSharedText) var generateSharedText

  enum Cancel {
    case currentUser
  }

  public var body: some Reducer<State, Action> {
    BindingReducer()
    Reduce<State, Action> { state, action in
      switch action {
      case .onTask:
        return .run { send in
          for try await data in godClient.currentUser() {
            await send(.currentUserResponse(.success(data)))
          }
        } catch: { error, send in
          await send(.currentUserResponse(.failure(error)))
        }
        .cancellable(id: Cancel.currentUser, cancelInFlight: true)

      case .onAppear:
        analytics.logScreen(screenName: "InviteFriend", of: self)
        return .none

      case .whyFriendsButtonTapped:
        state.destination = .alert(
          AlertState {
            TextState("To use God, you need friends from the same school 👥", bundle: .module)
          } actions: {
            ButtonState(action: .confirmOkay) {
              TextState("OK", bundle: .module)
            }
          } message: {
            TextState("God is by invitation only; send invitations to 5 people and you will be specifically invited.", bundle: .module)
          }
        )
        return .none

      case .inviteFriendButtonTapped:
        let remainingInvitationCount = state.remainingInvitationCount
        analytics.buttonClick(
          name: .requiredInviteFriend,
          parameters: [
            "remaining_invitation_count": remainingInvitationCount,
          ]
        )
        if remainingInvitationCount == 0 {
          return .send(.delegate(.nextScreen))
        }
        state.destination = .activity()
        return .none

      case let .currentUserResponse(.success(data)):
        state.receivedActivity = .init(currentUser: data.currentUser)
        return .run { send in
          await send(.generateSharedTextResponse(Result {
            try await generateSharedText(.invite, .share, .requiredInvite)
          }))
        }

      case let .generateSharedTextResponse(.success(text)):
        state.sharedText = text
        return .none

      case let .onCompletion(completion):
        state.destination = nil
        analytics.logEvent("activity_completion", [
          "activity_type": completion.activityType?.rawValue,
        ])
        guard
          completion.result,
          state.remainingInvitationCount > 0
        else { return .none }
        for i in 0 ..< state.invites.count {
          if !state.invites[i] {
            state.invites[i] = true
            break
          }
        }
        return .none

      case .destination(.presented(.alert(.confirmOkay))):
        state.destination = nil
        return .none

      default:
        return .none
      }
    }
    .ifLet(\.$destination, action: \.destination) {
      Destination()
    }
    .ifLet(\.receivedActivity, action: \.receivedActivity) {
      ReceivedActivityLogic()
    }
  }
}

public struct InviteFriendView: View {
  @StateObject var viewStore: ViewStoreOf<InviteFriendLogic>
  let store: StoreOf<InviteFriendLogic>

  public init(store: StoreOf<InviteFriendLogic>) {
    self.store = store
    _viewStore = StateObject(
      wrappedValue: ViewStore(store, observe: { $0 })
    )
  }

  public var body: some View {
    VStack(spacing: 20) {
      Text("Finally, please invite your friends\nInvite your friends", bundle: .module)
        .font(.system(.title, design: .rounded, weight: .black))
        .foregroundStyle(Color.white)

      Text("INVITE \(viewStore.remainingInvitationCount) FRIENDS", bundle: .module)
        .font(.system(.callout, design: .rounded, weight: .bold))
        .foregroundStyle(Color.white)
        .padding(.vertical, 6)
        .padding(.horizontal, 12)
        .background(Color.godService)
        .clipShape(Capsule())

      ScrollView(.horizontal, showsIndicators: false) {
        HStack(alignment: .top, spacing: 12) {
          ForEach(Array(viewStore.invites.enumerated()), id: \.offset) { offset, isInvited in
            Button {
              store.send(.inviteFriendButtonTapped)
            } label: {
              VStack(spacing: 8) {
                Group {
                  if isInvited {
                    LottieView(animation: LottieAnimation.named("Invited", bundle: .module))
                      .looping()
                      .resizable()
                  } else {
                    Image(systemName: "person.crop.circle.badge.plus")
                  }
                }
                .frame(width: 80, height: 80)
                .font(.system(size: 50))
                .clipShape(Circle())

                Text(isInvited ? "invited via\nother app" : "No friend\ninvited yet", bundle: .module)
                  .font(.system(.footnote, design: .rounded))
              }
              .frame(width: 80)
              .foregroundStyle(Color.godTextSecondaryDark)
            }
            .id(offset)
            .buttonStyle(HoldDownButtonStyle())
          }
        }
        .padding(.horizontal, 24)
      }

      VStack(spacing: 16) {
        Button {
          store.send(.whyFriendsButtonTapped)
        } label: {
          Label {
            Text("Why 5 friends", bundle: .module)
              .font(.system(.callout, design: .rounded, weight: .medium))
          } icon: {
            Image(systemName: "info.circle.fill")
          }
          .foregroundStyle(Color.yellow)
        }

        IfLetStore(
          store.scope(state: \.receivedActivity, action: \.receivedActivity)
        ) { store in
          ReceivedActivityView(store: store)
        } else: {
          ProgressView()
            .progressViewStyle(.circular)
            .tint(Color.white)
        }
      }
      .frame(maxHeight: .infinity, alignment: .top)

      Button {
        store.send(.inviteFriendButtonTapped)
      } label: {
        Group {
          if viewStore.remainingInvitationCount == 0 {
            Text("Start", bundle: .module)
              .font(.system(.body, design: .rounded, weight: .bold))
          } else {
            Label {
              Text("Invite \(viewStore.remainingInvitationCount) best friends", bundle: .module)
                .font(.system(.body, design: .rounded, weight: .bold))
            } icon: {
              Image(systemName: "square.and.arrow.up")
            }
          }
        }
        .frame(height: 54)
        .frame(maxWidth: .infinity)
        .background(Color.godService)
        .foregroundStyle(Color.white)
        .clipShape(Capsule())
      }
      .buttonStyle(HoldDownButtonStyle())
      .padding(.horizontal, 24)
    }
    .padding(.top, 16)
    .background(Color.godBlack)
    .multilineTextAlignment(.center)
    .navigationTitle(Text("Invite Friends", bundle: .module))
    .navigationBarTitleDisplayMode(.inline)
    .toolbarBackground(Color.godBlack, for: .navigationBar)
    .toolbarBackground(.visible, for: .navigationBar)
    .toolbarColorScheme(.dark, for: .navigationBar)
    .task { await store.send(.onTask).finish() }
    .onAppear { store.send(.onAppear) }
    .alert(
      store: store.scope(state: \.$destination.alert, action: \.destination.alert)
    )
    .sheet(
      store: store.scope(state: \.$destination.activity, action: \.destination.activity)
    ) { _ in
      ActivityView(
        activityItems: [viewStore.sharedText],
        applicationActivities: nil
      ) { activityType, result, _, _ in
        store.send(
          .onCompletion(
            InviteFriendLogic.CompletionWithItems(
              activityType: activityType,
              result: result
            )
          )
        )
      }
      .presentationDetents([.medium, .large])
    }
  }
}

#Preview {
  NavigationStack {
    InviteFriendView(
      store: .init(
        initialState: InviteFriendLogic.State(),
        reducer: { InviteFriendLogic() }
      )
    )
  }
  .environment(\.locale, Locale(identifier: "ja-JP"))
}
