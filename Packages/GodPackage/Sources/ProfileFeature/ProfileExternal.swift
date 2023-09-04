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
    case userResponse(TaskResult<God.UserQuery.Data>)
  }

  @Dependency(\.dismiss) var dismiss
  @Dependency(\.godClient) var godClient

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .onTask:
        enum Cancel { case id }
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
        state.user = .some(data.user)
        return .none

      case .userResponse(.failure):
        state.user = .none
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
          if case let .some(user) = viewStore.user {
            ProfileSection(
              user: user.fragments.profileSectionFragment,
              editProfile: nil
            )
          }
          Divider()

          TopStarsSection()
        }
      }
      .navigationTitle("Profile")
      .navigationBarTitleDisplayMode(.inline)
      .task { await viewStore.send(.onTask).finish() }
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
