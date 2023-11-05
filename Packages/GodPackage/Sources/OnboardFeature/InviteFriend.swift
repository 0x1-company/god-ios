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
    var remainingInvitationCount = 3
    @BindingState var isPresented = false

    public init() {}
  }

  public enum Action: Equatable, BindableAction {
    case onTask
    case onAppear
    case inviteFriendButtonTapped
    case onCompletion(CompletionWithItems)
    case binding(BindingAction<State>)
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
        
      case .inviteFriendButtonTapped:
        state.isPresented = true
        return .none
        
      case let .onCompletion(completion):
        state.isPresented = false
        guard
          completion.result,
          state.remainingInvitationCount > 0
        else { return .none }
        state.remainingInvitationCount -= 1
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
        
        HStack(spacing: 24) {
          ForEach(0..<3) { _ in
            VStack(spacing: 12) {
              Color.red
                .frame(width: 80, height: 80)
                .clipShape(Circle())

              Text("No friend\ninvited yet", bundle: .module)
                .foregroundStyle(Color.godTextSecondaryDark)
                .font(.system(.body, design: .rounded))
            }
          }
        }
        
        Label {
          Text("Why 3 friends", bundle: .module)
            .font(.system(.body, design: .rounded))
        } icon: {
          Image(systemName: "info.circle.fill")
        }
        .foregroundStyle(Color.yellow)
        
        Spacer()
        
        Button {
          store.send(.inviteFriendButtonTapped)
        } label: {
          Label {
            Text("Invite \(viewStore.remainingInvitationCount) best friends", bundle: .module)
              .font(.system(.body, design: .rounded, weight: .bold))
          } icon: {
            Image(systemName: "square.and.arrow.up")
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
