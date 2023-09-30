import ButtonStyles
import Colors
import ComposableArchitecture
import God
import GodClient
import SwiftUI

public struct ShareTheAppLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    var currentUser: God.CurrentUserQuery.Data.CurrentUser?
    public init() {}
  }

  public enum Action: Equatable {
    case onTask
    case shareTheAppButtonTapped
    case currentUserResponse(TaskResult<God.CurrentUserQuery.Data>)
  }
  
  @Dependency(\.openURL) var openURL
  @Dependency(\.godClient) var godClient

  public var body: some Reducer<State, Action> {
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

      case .shareTheAppButtonTapped:
        guard
          let schoolName = state.currentUser?.school?.name,
          let username = state.currentUser?.username
        else { return .none }
        let text = """
        \(schoolName)向けの新しいアプリダウンロードしてみて！
        https://godapp.jp/invite/\(username)
        """
        guard let url = URL(string: "https://line.me/R/share?text=\(text)")
        else { return .none }

        return .run { _ in
          await openURL(url)
        }
      case let .currentUserResponse(.success(data)):
        state.currentUser = data.currentUser
        return .none

      case .currentUserResponse(.failure):
        state.currentUser = nil
        return .none
      }
    }
  }
}

public struct ShareTheAppView: View {
  let store: StoreOf<ShareTheAppLogic>

  public init(store: StoreOf<ShareTheAppLogic>) {
    self.store = store
  }

  public var body: some View {
    ZStack {
      Color.godService
        .ignoresSafeArea()
      VStack(spacing: 20) {
        Text("Get more\nfriends to play")
          .font(.title2)
          .foregroundStyle(Color.white)

        ShareLink(
          item: URL(string: "https://godapp.jp")!
        ) {
          Text("Share the app")
            .bold()
            .frame(width: 188, height: 54)
            .background(Color.white)
            .clipShape(Capsule())
        }
        .buttonStyle(HoldDownButtonStyle())
      }
      .multilineTextAlignment(.center)
    }
    .task { await store.send(.onTask).finish() }
  }
}

#Preview {
  ShareTheAppView(
    store: .init(
      initialState: ShareTheAppLogic.State(),
      reducer: { ShareTheAppLogic() }
    )
  )
}
