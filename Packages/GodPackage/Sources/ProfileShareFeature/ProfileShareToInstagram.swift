import AnimationDisableTransaction
import ButtonStyles
import Colors
import ComposableArchitecture
import God
import GodClient
import SwiftUI

public struct ProfileShareToInstagramLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    var profileLinkString: String?
    var isProfileLinkCopied: Bool = false
    public init() {}
  }

  public enum Action: Equatable {
    case onTask
    case currentUserResponse(TaskResult<God.CurrentUserQuery.Data>)
    case copyLinkButtonTapped
    case closeButtonTapped
    case shareButtonTapped
    case delegate(Delegate)

    public enum Delegate {
      case nextPage
    }
  }

  @Dependency(\.godClient) var godClient
  @Dependency(\.dismiss) var dismiss

  public var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .onTask:
        enum Cancel { case id }
        return .run { send in
          for try await data in godClient.currentUser() {
            await send(.currentUserResponse(.success(data)))
          }
        } catch: { error, send in
          await send(.currentUserResponse(.failure(error)))
        }
        .cancellable(id: Cancel.id)

      case let .currentUserResponse(.success(response)):
        guard let username = response.currentUser.username else {
          return .none
        }
        state.profileLinkString = "https://a.app/\(username)"
        return .none

      case .currentUserResponse(.failure):
        assertionFailure()
        return .run { _ in
          await dismiss()
        }

      case .copyLinkButtonTapped:
        // TODO: LINK
        UIPasteboard.general.string = "https://a.app/username"
        state.isProfileLinkCopied = true
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
            .font(.title)
            .bold()
            .foregroundColor(.godBlack)
            .lineSpacing(-2)
            .lineLimit(2)
            .multilineTextAlignment(.center)
        }

        VStack(alignment: .center, spacing: 16) {
          VStack(alignment: .center, spacing: 0) {
            Text("Step1", bundle: .module)
              .bold()
            Text("Copy your god link", bundle: .module)
          }
          .font(.title2)

          Text(viewStore.state.profileLinkString ?? "")
            .font(.body)
            .foregroundColor(.godTextSecondaryDark)
            .frame(maxWidth: .infinity, alignment: .center)
            .frame(height: 52)
            .background(Color(red: 243 / 255, green: 243 / 255, blue: 243 / 255))
            .cornerRadius(26)

          Button {
            viewStore.send(.copyLinkButtonTapped)
          } label: {
            Text(viewStore.state.isProfileLinkCopied ? "Link Copied!" : "Copy Link", bundle: .module)
              .font(.subheadline)
              .bold()
              .foregroundColor(.godService)
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
          VStack(alignment: .center, spacing: 0) {
            Text("Step2", bundle: .module)
              .bold()
            Text("Post on your story", bundle: .module)
          }
          .font(.title2)

          Button {
            viewStore.send(.shareButtonTapped)
          } label: {
            Text("Share", bundle: .module)
              .font(.subheadline)
              .bold()
              .foregroundColor(.godWhite)
              .frame(maxWidth: .infinity)
              .frame(height: 52)
              .background(Color(red: 247 / 255, green: 108 / 255, blue: 67 / 255))
              .cornerRadius(26)
          }
          .buttonStyle(HoldDownButtonStyle())
        }
      }
      .padding(20)
      .background(Color.godWhite)
      .cornerRadius(24)
      .task { await viewStore.send(.onTask).finish() }
    }
  }
}

struct ProfileShareToInstagramViewPreviews: PreviewProvider {
  static var previews: some View {
    Text("ProfileShareToInstagram")
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
}
