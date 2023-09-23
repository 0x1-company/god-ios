import AsyncValue
import ComposableArchitecture
import God
import GodClient
import SwiftUI

public struct ProfileExternalLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    var userId: String
    var user = AsyncValue<God.UserQuery.Data.User>.none

    public init(userId: String) {
      self.userId = userId
    }
  }

  public enum Action: Equatable {
    case onTask
    case closeButtonTapped
    case userResponse(TaskResult<God.UserQuery.Data>)
  }

  @Dependency(\.dismiss) var dismiss
  @Dependency(\.godClient) var godClient

  public var body: some Reducer<State, Action> {
    Reduce<State, Action> { state, action in
      switch action {
      case .onTask:
        enum Cancel { case id }
        state.user = .loading
        let userWhere = God.UserWhere(id: .init(stringLiteral: state.userId))
        return .run { send in
          for try await data in godClient.user(userWhere) {
            await send(.userResponse(.success(data)))
          }
        } catch: { error, send in
          await send(.userResponse(.failure(error)))
        }
        .cancellable(id: Cancel.id)

      case let .userResponse(.success(data)):
        state.user = .success(data.user)
        return .none

      case .userResponse(.failure):
        state.user = .none
        return .run { _ in
          await dismiss()
        }
      case .closeButtonTapped:
        return .run { _ in
          await dismiss()
        }
      }
    }
  }
}

public struct ProfileExternalView: View {
  let store: StoreOf<ProfileExternalLogic>

  public init(store: StoreOf<ProfileExternalLogic>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      ScrollView {
        LazyVStack(alignment: .leading, spacing: 0) {
          if case let .success(user) = viewStore.user {
            ProfileSection(
              imageURL: user.imageURL,
              friendsCount: user.friendsCount ?? 0,
              votedCount: user.votedCount,
              username: user.username ?? "",
              firstName: user.firstName,
              lastName: user.lastName,
              displayName: user.displayName.ja,
              schoolShortName: user.school?.shortName,
              grade: user.grade
            )
          } else if case .loading = viewStore.user {
            ProgressView()
              .progressViewStyle(.circular)
              .frame(width: .infinity, alignment: .center)
          }
          Divider()

          TopStarsSection()
        }
      }
      .navigationTitle(Text("Profile", bundle: .module))
      .navigationBarTitleDisplayMode(.inline)
      .task { await viewStore.send(.onTask).finish() }
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          Button {
            viewStore.send(.closeButtonTapped)
          } label: {
            Image(systemName: "xmark")
              .foregroundStyle(Color.secondary)
          }
        }
      }
    }
  }
}

struct ProfileExternalViewPreviews: PreviewProvider {
  static var previews: some View {
    ProfileExternalView(
      store: .init(
        initialState: ProfileExternalLogic.State(userId: ""),
        reducer: { ProfileExternalLogic() }
      )
    )
  }
}
