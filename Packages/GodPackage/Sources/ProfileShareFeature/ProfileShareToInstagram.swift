import AnalyticsClient
import AnimationDisableTransaction
import ComposableArchitecture
import God
import GodClient
import ShareLinkBuilder
import Styleguide
import SwiftUI
import UIPasteboardClient

public struct ProfileShareToInstagramLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    var username: String?
    var isProfileLinkCopied: Bool = false
    public init() {}
  }

  public enum Action: Equatable {
    case onTask
    case onAppear
    case currentUserResponse(TaskResult<God.CurrentUserQuery.Data>)
    case copyLinkButtonTapped
    case closeButtonTapped
    case shareButtonTapped
    case delegate(Delegate)

    public enum Delegate {
      case nextPage
    }
  }

  @Dependency(\.dismiss) var dismiss
  @Dependency(\.godClient) var godClient
  @Dependency(\.analytics) var analytics
  @Dependency(\.pasteboard) var pasteboard

  public var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .onTask:
        return .run { send in
          for try await data in godClient.currentUser() {
            await send(.currentUserResponse(.success(data)))
          }
        } catch: { error, send in
          await send(.currentUserResponse(.failure(error)))
        }

      case .onAppear:
        analytics.logScreen(screenName: "ProfileShareToInstagram", of: self)
        return .none

      case let .currentUserResponse(.success(data)):
        state.username = data.currentUser.username
        return .none

      case .currentUserResponse(.failure):
        return .run { _ in
          await dismiss()
        }

      case .copyLinkButtonTapped:
        guard let username = state.username else {
          return .none
        }
        let shareLink = ShareLinkBuilder.buildGodLink(
          path: .add,
          username: username,
          source: .instagram,
          medium: .profile
        )
        pasteboard.url(shareLink)
        state.isProfileLinkCopied = true
        analytics.buttonClick(name: .copyLink, parameters: ["url": shareLink.absoluteString])
        return .none

      case .closeButtonTapped:
        return .run { _ in
          await dismiss()
        }

      case .shareButtonTapped:
        return .send(.delegate(.nextPage))
          .transaction(.animationDisable)

      case .delegate:
        return .none
      }
    }
  }
}

public struct ProfileShareToInstagramView: View {
  public static let heightForPresentationDetents: CGFloat = 260
  let store: StoreOf<ProfileShareToInstagramLogic>

  public init(store: StoreOf<ProfileShareToInstagramLogic>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      VStack(alignment: .center, spacing: 24) {
        VStack(alignment: .center, spacing: 16) {
          Image(ImageResource.instagram)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 60, height: 60)
            .clipShape(Circle())

          Text("Share Profile on\nInstagram", bundle: .module)
            .font(.system(.title, design: .rounded, weight: .bold))
            .foregroundStyle(.godBlack)
            .multilineTextAlignment(.center)
        }

        VStack(alignment: .center, spacing: 16) {
          VStack(alignment: .center, spacing: 8) {
            Text("Step 1", bundle: .module)
              .font(.system(.title2, design: .rounded, weight: .bold))
            Text("Copy your God link", bundle: .module)
              .font(.system(.headline, design: .rounded, weight: .bold))
          }

          Text(verbatim: "godapp.jp/@\(viewStore.username ?? "")")
            .font(.system(.body, design: .rounded, weight: .bold))
            .foregroundStyle(.godTextSecondaryDark)
            .frame(maxWidth: .infinity, alignment: .center)
            .frame(height: 52)
            .background(Color(red: 243 / 255, green: 243 / 255, blue: 243 / 255))
            .cornerRadius(26)

          Button {
            viewStore.send(.copyLinkButtonTapped)
          } label: {
            Text(viewStore.state.isProfileLinkCopied ? "Link Copied!" : "Copy Link", bundle: .module)
              .font(.system(.body, design: .rounded, weight: .bold))
              .foregroundStyle(.godService)
              .frame(maxWidth: .infinity)
              .frame(height: 52)
              .cornerRadius(26)
              .overlay(
                RoundedRectangle(cornerRadius: 26)
                  .stroke(Color.godService, lineWidth: 0.5)
              )
          }
          .buttonStyle(HoldDownButtonStyle())
        }

        VStack(alignment: .center, spacing: 16) {
          VStack(alignment: .center, spacing: 8) {
            Text("Step 2", bundle: .module)
              .font(.system(.title2, design: .rounded, weight: .bold))
            Text("Post on your story", bundle: .module)
              .font(.system(.headline, design: .rounded, weight: .bold))
          }

          Button {
            viewStore.send(.shareButtonTapped)
          } label: {
            Text("Share", bundle: .module)
              .font(.system(.body, design: .rounded, weight: .bold))
              .foregroundStyle(.godWhite)
              .frame(maxWidth: .infinity)
              .frame(height: 52)
              .background(Color.godService)
              .cornerRadius(26)
          }
          .buttonStyle(HoldDownButtonStyle())
        }
      }
      .padding(20)
      .background(Color.godWhite)
      .cornerRadius(24)
      .task { await viewStore.send(.onTask).finish() }
      .onAppear { store.send(.onAppear) }
    }
  }
}

#Preview {
  Color.red
    .sheet(
      isPresented: .constant(true)
    ) {
      ProfileShareToInstagramView(
        store: .init(
          initialState: ProfileShareToInstagramLogic.State(),
          reducer: { ProfileShareToInstagramLogic() }
        )
      )
      .presentationDetents([.fraction(0.3)])
      .presentationDragIndicator(.visible)
    }
}
