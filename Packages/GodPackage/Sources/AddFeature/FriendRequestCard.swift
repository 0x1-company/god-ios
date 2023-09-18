import ButtonStyles
import Colors
import ComposableArchitecture
import God
import GodClient
import SwiftUI

public struct FriendRequestCardLogic: Reducer {
  public init() {}

  public struct State: Equatable, Identifiable {
    public var id: String {
      return friendId
    }
    var friendId: String
    var userId: String
    var displayName: String
    var description: String

    public init(
      friendId: String,
      userId: String,
      displayName: String,
      description: String
    ) {
      self.friendId = friendId
      self.userId = userId
      self.displayName = displayName
      self.description = description
    }
  }

  public enum Action: Equatable {
    case approveButtonTapped
    case hideButtonTapped
    case approveResponse(TaskResult<God.ApproveFriendRequestMutation.Data>)
    case hideResponse(TaskResult<God.CreateUserHideMutation.Data>)
  }
  
  @Dependency(\.godClient) var godClient

  public var body: some Reducer<State, Action> {
    Reduce<State, Action> { state, action in
      switch action {
      case .approveButtonTapped:
        let input = God.ApproveFriendRequestInput(id: state.friendId)
        return .run { send in
          await send(.approveResponse(TaskResult {
            try await godClient.approveFriendRequest(input)
          }))
        }
      case .hideButtonTapped:
        let input = God.CreateUserHideInput(hiddenUserId: state.userId)
        return .run { send in
          await send(.hideResponse(TaskResult {
            try await godClient.createUserHide(input)
          }))
        }
      case .approveResponse(.success):
        return .none

      case .approveResponse(.failure):
        return .none

      case .hideResponse(.success):
        return .none

      case .hideResponse(.failure):
        return .none
      }
    }
  }
}

public struct FriendRequestCardView: View {
  let store: StoreOf<FriendRequestCardLogic>

  public init(store: StoreOf<FriendRequestCardLogic>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      HStack(alignment: .center, spacing: 16) {
        Color.red
          .frame(width: 40, height: 40)
          .clipShape(Circle())

        VStack(alignment: .leading) {
          Text(verbatim: viewStore.displayName)

          Text(verbatim: viewStore.description)
            .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)

        HStack(spacing: 0) {
          Button {
            viewStore.send(.hideButtonTapped)
          } label: {
            Text("HIDE", bundle: .module)
              .frame(width: 80, height: 34)
              .foregroundStyle(.secondary)
          }

          Button {
            viewStore.send(.approveButtonTapped)
          } label: {
            Text("APPROVE", bundle: .module)
              .foregroundStyle(Color.white)
              .frame(height: 34)
              .frame(minWidth: 80, maxWidth: 120)
              .background(Color.godService)
              .clipShape(Capsule())
          }
        }
        .buttonStyle(HoldDownButtonStyle())
      }
      .frame(height: 72)
      .padding(.horizontal, 16)
    }
  }
}

#Preview {
  FriendRequestCardView(
    store: .init(
      initialState: FriendRequestCardLogic.State(
        friendId: "1",
        userId: "3",
        displayName: "Tomoki Tsukiyama",
        description: "1 mutual friend"
        
      ),
      reducer: { FriendRequestCardLogic() }
    )
  )
}
