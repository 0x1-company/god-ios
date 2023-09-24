import ButtonStyles
import Colors
import ComposableArchitecture
import God
import GodClient
import SearchField
import SwiftUI

public struct PickFriendToAddYourNameTheirPollLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    @BindingState var searchQuery = ""
    var friends: [God.FriendFragment] = []
    var selection: God.FriendFragment?
    public init() {}
  }

  public enum Action: Equatable, BindableAction {
    case onTask
    case nextButtonTapped
    case closeButtonTapped
    case friendButtonTapped(God.FriendFragment)
    case friendsResponse(TaskResult<God.FriendsQuery.Data>)
    case binding(BindingAction<State>)
    case delegate(Delegate)

    public enum Delegate: Equatable {
      case purchase(userId: String)
    }
  }

  @Dependency(\.dismiss) var dismiss
  @Dependency(\.godClient) var godClient

  public var body: some Reducer<State, Action> {
    BindingReducer()
    Reduce<State, Action> { state, action in
      switch action {
      case .onTask:
        return .run { send in
          for try await data in godClient.friends() {
            await send(.friendsResponse(.success(data)))
          }
        } catch: { error, send in
          await send(.friendsResponse(.failure(error)))
        }
      case .nextButtonTapped:
        guard let userId = state.selection?.id
        else { return .none }
        return .send(.delegate(.purchase(userId: userId)), animation: .default)

      case .closeButtonTapped:
        return .run { _ in
          await dismiss()
        }
      case let .friendButtonTapped(friend):
        state.selection = friend
        return .none

      case let .friendsResponse(.success(data)):
        state.friends = data.friends.map(\.fragments.friendFragment)
        return .none

      case .friendsResponse(.failure):
        state.friends = []
        return .none

      case .binding:
        return .none

      case .delegate:
        return .none
      }
    }
  }
}

public struct PickFriendToAddYourNameTheirPollView: View {
  let store: StoreOf<PickFriendToAddYourNameTheirPollLogic>
  
  public init(store: StoreOf<PickFriendToAddYourNameTheirPollLogic>) {
    self.store = store
  }
  
  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      VStack(spacing: 0) {
        Text("Pick a friend to add\nyour name to their polls", bundle: .module)
          .bold()
          .font(.title2)
          .foregroundStyle(Color.godWhite)
          .multilineTextAlignment(.center)
          .frame(maxWidth: .infinity)
          .padding(.bottom, 46)
          .background(Color.godService)
        
        SearchField(text: viewStore.$searchQuery)
        
        Divider()
        
        List(viewStore.friends, id: \.self) { friend in
          Button {
            viewStore.send(.friendButtonTapped(friend))
          } label: {
            HStack(spacing: 16) {
              Color.red
                .frame(width: 42, height: 42)
                .clipShape(Circle())
              
              Text(friend.displayName.ja)
                .frame(maxWidth: .infinity, alignment: .leading)
              
              Rectangle()
                .fill(viewStore.selection == friend ? Color.godService : Color.white)
                .frame(width: 26, height: 26)
                .clipShape(Circle())
                .overlay(
                  RoundedRectangle(cornerRadius: 26 / 2)
                    .stroke(viewStore.selection == friend ? Color.godService : Color.godTextSecondaryLight, lineWidth: 2)
                )
            }
            .frame(height: 76)
            .padding(.horizontal, 16)
          }
        }
        .listStyle(.plain)
      }
      .task { await viewStore.send(.onTask).finish() }
      .toolbar {
        ToolbarItem(placement: .topBarLeading) {
          Button {
            viewStore.send(.closeButtonTapped)
          } label: {
            Image(systemName: "xmark")
              .foregroundStyle(.white)
          }
          .buttonStyle(HoldDownButtonStyle())
        }
        ToolbarItem(placement: .topBarTrailing) {
          Button {
            viewStore.send(.nextButtonTapped)
          } label: {
            Text("Next", bundle: .module)
              .bold()
              .foregroundStyle(.white)
              .disabled(viewStore.selection == nil)
          }
          .buttonStyle(HoldDownButtonStyle())
        }
      }
    }
  }
}

#Preview {
  NavigationStack {
    PickFriendToAddYourNameTheirPollView(
      store: .init(
        initialState: PickFriendToAddYourNameTheirPollLogic.State(),
        reducer: { PickFriendToAddYourNameTheirPollLogic() }
      )
    )
  }
}
