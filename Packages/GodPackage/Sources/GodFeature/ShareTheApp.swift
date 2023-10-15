import ComposableArchitecture
import God
import GodClient
import Styleguide
import SwiftUI
import ShareLinkBuilder

public struct ShareTheAppLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    var shareURL = URL(string: "https://godapp.jp")!
    public init() {}
  }

  public enum Action: Equatable {
    case onTask
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

      case let .currentUserResponse(.success(data)):
        guard let shareURL = ShareLinkBuilder.buildForLine(path: .invite, username: data.currentUser.username)
        else { return .none }
        
        state.shareURL = shareURL

        return .none

      case .currentUserResponse(.failure):
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
    WithViewStore(store, observe: { $0 }) { viewStore in
      ZStack {
        Color.godService
          .ignoresSafeArea()
        VStack(spacing: 24) {
          Image(ImageResource.upsideDownFace)
            .resizable()
            .aspectRatio(1, contentMode: .fit)
            .frame(width: 120)
          Text("Get more\nfriends to play", bundle: .module)
            .font(.title2)
            .foregroundStyle(Color.white)

          ShareLink(
            item: viewStore.shareURL
          ) {
            Text("Share the app", bundle: .module)
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
}

#Preview {
  ShareTheAppView(
    store: .init(
      initialState: ShareTheAppLogic.State(),
      reducer: { ShareTheAppLogic() }
    )
  )
}
