import ActivityView
import AnalyticsClient
import ComposableArchitecture
import Styleguide
import SwiftUI

public struct InviteFriendLogic: Reducer {
  public init() {}
  
  public struct CompletionWithItems: Equatable {
    public let activityType: UIActivity.ActivityType?
    public let result: Bool
  }

  public struct State: Equatable {
    var remainingInvitationCount: Int {
      return invites.filter { !$0 }.count
    }
    var invites = Array(repeating: false, count: 3)
    @BindingState var isPresented = false
    @PresentationState var alert: AlertState<Action.Alert>?

    public init() {}
  }

  public enum Action: Equatable, BindableAction {
    case onTask
    case onAppear
    case whyFriendsButtonTapped
    case inviteFriendButtonTapped
    case onCompletion(CompletionWithItems)
    case binding(BindingAction<State>)
    case alert(PresentationAction<Alert>)
    case delegate(Delegate)
    
    public enum Alert: Equatable {
      case confirmOkay
    }
    
    public enum Delegate: Equatable {
      case nextScreen
    }
  }

  @Dependency(\.analytics) var analytics

  public var body: some Reducer<State, Action> {
    BindingReducer()
    Reduce<State, Action> { state, action in
      switch action {
      case .onTask:
        return .none

      case .onAppear:
        analytics.logScreen(screenName: "InviteFriend", of: self)
        return .none
        
      case .whyFriendsButtonTapped:
        state.alert = AlertState {
          TextState("To use God, you need friends from the same school 👥", bundle: .module)
        } actions: {
          ButtonState(action: .confirmOkay) {
            TextState("OK", bundle: .module)
          }
        } message: {
          TextState("God is by invitation only; send invitations to 3 people and you will be specifically invited.", bundle: .module)
        }
        return .none
        
      case .inviteFriendButtonTapped where state.remainingInvitationCount == 0:
        return .send(.delegate(.nextScreen))
        
      case .inviteFriendButtonTapped:
        state.isPresented = true
        return .none
        
      case let .onCompletion(completion):
        state.isPresented = false
        guard
          completion.result,
          state.remainingInvitationCount > 0
        else { return .none }
        for i in 0..<state.invites.count {
          if !state.invites[i] {
            state.invites[i] = true
            break
          }
        }
        return .none
        
      case .alert(.presented(.confirmOkay)):
        state.alert = nil
        return .none
        
      default:
        return .none
      }
    }
  }
}

public struct InviteFriendView: View {
  let store: StoreOf<InviteFriendLogic>

  public init(store: StoreOf<InviteFriendLogic>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      VStack(spacing: 28) {
        Text("Finally, please invite your friends\nInvite your friends", bundle: .module)
          .font(.system(.title, design: .rounded, weight: .black))
          .foregroundStyle(Color.white)
        
        Text("INVITE \(viewStore.remainingInvitationCount) FRIENDS", bundle: .module)
          .font(.system(.body, design: .rounded, weight: .bold))
          .foregroundStyle(Color.white)
          .padding(.vertical, 4)
          .padding(.horizontal, 12)
          .background(Color.godService)
          .clipShape(Capsule())
        
        HStack(alignment: .top, spacing: 24) {
          ForEach(viewStore.invites, id: \.self) { isInvited in
            Button {
              store.send(.inviteFriendButtonTapped)
            } label: {
              VStack(spacing: 12) {
                Image(systemName: "person.crop.circle.badge.plus")
                  .frame(width: 80, height: 80)
                  .font(.system(size: 50))
                  .clipShape(Circle())
                
                Text(isInvited ? "invited via\nother app" : "No friend\ninvited yet", bundle: .module)
                  .font(.system(.body, design: .rounded))
              }
              .foregroundStyle(Color.godTextSecondaryDark)
            }
          }
        }
        
        Button {
          store.send(.whyFriendsButtonTapped)
        } label: {
          Label {
            Text("Why 3 friends", bundle: .module)
              .font(.system(.body, design: .rounded))
          } icon: {
            Image(systemName: "info.circle.fill")
          }
          .foregroundStyle(Color.yellow)
        }
        
        Spacer()
        
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
      .background(Color.godBlack)
      .multilineTextAlignment(.center)
      .navigationTitle(Text("Invite Friends", bundle: .module))
      .navigationBarTitleDisplayMode(.inline)
      .toolbarBackground(Color.godBlack, for: .navigationBar)
      .toolbarBackground(.visible, for: .navigationBar)
      .toolbarColorScheme(.dark, for: .navigationBar)
      .task { await store.send(.onTask).finish() }
      .onAppear { store.send(.onAppear) }
      .alert(store: store.scope(state: \.$alert, action: InviteFriendLogic.Action.alert))
      .sheet(isPresented: viewStore.$isPresented) {
        ActivityView(
          activityItems: [URL(string: "https://tomokisun.com")!],
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
