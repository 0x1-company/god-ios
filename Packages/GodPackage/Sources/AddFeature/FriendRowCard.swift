import ButtonStyles
import Colors
import ComposableArchitecture
import God
import GodClient
import ProfileImage
import SwiftUI

public struct FriendRowCardLogic: Reducer {
  public init() {}

  public struct State: Equatable, Identifiable {
    public var id: String
    var imageURL: String
    var displayName: String
    var firstName: String
    var lastName: String
    var description: String
    var friendStatus = God.FriendStatus.canceled
  }

  public enum Action: Equatable {
    case addButtonTapped
    case hideButtonTapped
    case friendRequestResponse(TaskResult<God.CreateFriendRequestMutation.Data>)
    case hideResponse(TaskResult<God.CreateUserHideMutation.Data>)
    case delegate(Delegate)
    
    public enum Delegate: Equatable {
      case requested
    }
  }

  @Dependency(\.godClient) var godClient

  public var body: some Reducer<State, Action> {
    Reduce<State, Action> { state, action in
      switch action {
      case .addButtonTapped:
        state.friendStatus = .requested
        let input = God.CreateFriendRequestInput(toUserId: state.id)
        return .run { send in
          await send(.friendRequestResponse(TaskResult {
            try await godClient.createFriendRequest(input)
          }))
        }
      case .hideButtonTapped:
        let input = God.CreateUserHideInput(hiddenUserId: state.id)
        return .run { send in
          await send(.hideResponse(TaskResult {
            try await godClient.createUserHide(input)
          }))
        }
      case let .friendRequestResponse(.success(data)):
        guard let status = data.createFriendRequest.status.value
        else { return .none }
        state.friendStatus = status
        return .send(.delegate(.requested))

      case .friendRequestResponse(.failure):
        state.friendStatus = .canceled
        return .none

      default:
        return .none
      }
    }
  }
}

public struct FriendRowCardView: View {
  let store: StoreOf<FriendRowCardLogic>

  public init(store: StoreOf<FriendRowCardLogic>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      HStack(alignment: .center, spacing: 16) {
        ProfileImage(
          urlString: viewStore.imageURL,
          name: viewStore.firstName,
          size: 42
        )

        VStack(alignment: .leading) {
          Text(verbatim: viewStore.displayName)
            .bold()

          Text(verbatim: viewStore.description)
            .foregroundStyle(.secondary)
            .font(.footnote)
        }
        .frame(maxWidth: .infinity, alignment: .leading)

        HStack(spacing: 0) {
          Button {
            viewStore.send(.addButtonTapped)
          } label: {
            Group {
              if case .requested = viewStore.friendStatus {
                Text("REQUESTED", bundle: .module)
                  .foregroundStyle(Color.godTextSecondaryLight)
                  .frame(height: 34)
                  .padding(.horizontal, 8)
                  .overlay(
                    RoundedRectangle(cornerRadius: 34 / 2)
                      .stroke(Color.godTextSecondaryLight, lineWidth: 1)
                  )
              } else {
                Text("ADD", bundle: .module)
                  .font(.callout)
                  .bold()
                  .foregroundStyle(Color.white)
                  .frame(height: 34)
                  .padding(.horizontal, 12)
                  .background(Color.godService)
                  .clipShape(Capsule())
              }
            }
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
  FriendRowCardView(
    store: .init(
      initialState: FriendRowCardLogic.State(
        id: "1",
        imageURL: "",
        displayName: "Taro Tanaka",
        firstName: "Taro",
        lastName: "Tanaka",
        description: "Grade 9"
      ),
      reducer: { FriendRowCardLogic() }
    )
  )
}
