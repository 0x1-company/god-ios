import AnimationDisableTransaction
import BackgroundClearSheet
import ComposableArchitecture
import CupertinoMessageFeature
import God
import GodClient
import ShareLinkBuilder
import Styleguide
import SwiftUI

public struct ProfileShareLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    var lineURL = URL(string: "https://godapp.jp")!
    var shareURL = URL(string: "https://godapp.jp")!
    var smsText = ""
    var currentUser: God.CurrentUserQuery.Data.CurrentUser?
    @PresentationState var destination: Destination.State?
    @PresentationState var message: CupertinoMessageLogic.State?
    public init() {}
  }

  public enum Action: Equatable {
    case onTask
    case contentButtonTapped(Content)
    case closeButtonTapped
    case currentUserResponse(TaskResult<God.CurrentUserQuery.Data>)
    case destination(PresentationAction<Destination.Action>)
    case message(PresentationAction<CupertinoMessageLogic.Action>)
  }

  @Dependency(\.dismiss) var dismiss
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

      case .contentButtonTapped(.instagram):
        state.destination = .shareProfileToInstagramPopup()
        return .none

      case .contentButtonTapped(.line):
        return .run { [url = state.lineURL] _ in
          await openURL(url)
        }

      case .contentButtonTapped(.messages):
        state.message = .init(recipients: [], body: state.smsText)
        return .none

      case .closeButtonTapped:
        return .run { _ in
          await dismiss()
        }

      case let .currentUserResponse(.success(data)):
        guard let username = data.currentUser.username else { return .none }
        state.shareURL = ShareLinkBuilder.buildGodLink(
          path: .add,
          username: username,
          source: .share,
          medium: .profile
        )
        if let smsText = ShareLinkBuilder.buildShareText(path: .add, username: username, source: .sms, medium: .profile) {
          state.smsText = smsText
        }
        if let lineURL = ShareLinkBuilder.buildForLine(path: .add, username: username) {
          state.lineURL = lineURL
        }
        return .none

      default:
        return .none
      }
    }
    .ifLet(\.$destination, action: /Action.destination) {
      Destination()
    }
    .ifLet(\.$message, action: /Action.message) {
      CupertinoMessageLogic()
    }
  }

  public struct Destination: Reducer {
    public enum State: Equatable {
      case shareProfileToInstagramPopup(ShareProfileToInstagramPopupLogic.State = .init())
    }

    public enum Action: Equatable {
      case shareProfileToInstagramPopup(ShareProfileToInstagramPopupLogic.Action)
    }

    public var body: some Reducer<State, Action> {
      Scope(state: /State.shareProfileToInstagramPopup, action: /Action.shareProfileToInstagramPopup) {
        ShareProfileToInstagramPopupLogic()
      }
    }
  }

  public enum Content: CaseIterable {
    case instagram
    case line
    case messages
    case other

    public var name: LocalizedStringKey {
      switch self {
      case .instagram: return "Story"
      case .line: return "LINE"
      case .messages: return "Messages"
      case .other: return "Other"
      }
    }
  }
}

public struct ProfileShareView: View {
  public static let heightForPresentationDetents: CGFloat = 260
  let store: StoreOf<ProfileShareLogic>

  public init(store: StoreOf<ProfileShareLogic>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      VStack(alignment: .center, spacing: 28) {
        Text("Share Profile", bundle: .module)
          .font(.title3)
          .bold()

        HStack {
          Spacer()
          ForEach(ProfileShareLogic.Content.allCases, id: \.self) { content in
            switch content {
            case .instagram, .line:
              ShareButton(content: content) {
                store.send(.contentButtonTapped(content))
              }
            case .messages:
              Button {
                store.send(.contentButtonTapped(content))
              } label: {
                VStack(spacing: 12) {
                  Image(systemName: "message.fill")
                    .font(.system(size: 34))
                    .frame(width: 60, height: 60)
                    .foregroundStyle(Color.white)
                    .background(Color.green.gradient)
                    .clipShape(Circle())

                  Text(content.name, bundle: .module)
                    .font(.callout)
                    .bold()
                    .foregroundColor(.godBlack)
                }
              }
            case .other:
              ShareLink(item: viewStore.shareURL) {
                VStack(spacing: 12) {
                  Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 40))
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())

                  Text(content.name, bundle: .module)
                    .font(.callout)
                    .bold()
                    .foregroundColor(.godBlack)
                }
              }
            }
            Spacer()
          }
          .buttonStyle(HoldDownButtonStyle())
        }

        Button {
          viewStore.send(.closeButtonTapped)
        } label: {
          Text("Close", bundle: .module)
            .bold()
            .frame(height: 52)
            .frame(maxWidth: .infinity)
            .foregroundColor(.black)
            .overlay(
              RoundedRectangle(cornerRadius: 52 / 2)
                .stroke(Color.primary, lineWidth: 1)
            )
        }
        .buttonStyle(HoldDownButtonStyle())
      }
      .padding(.top, 24)
      .padding(.horizontal, 16)
      .task { await viewStore.send(.onTask).finish() }
      .sheet(
        store: store.scope(state: \.$message, action: { .message($0) }),
        content: CupertinoMessageView.init
      )
      .fullScreenCover(
        store: store.scope(state: \.$destination, action: { .destination($0) }),
        state: /ProfileShareLogic.Destination.State.shareProfileToInstagramPopup,
        action: ProfileShareLogic.Destination.Action.shareProfileToInstagramPopup
      ) { store in
        ShareProfileToInstagramPopupView(store: store)
          .backgroundClearSheet()
      }
    }
  }

  struct ShareButton: View {
    let content: ProfileShareLogic.Content
    let action: () -> Void

    var body: some View {
      Button(action: action) {
        VStack(spacing: 12) {
          switch content {
          case .instagram:
            Image(ImageResource.instagram)
              .resizable()
              .aspectRatio(contentMode: .fit)
              .frame(width: 60, height: 60)
              .clipShape(Circle())
          case .line:
            Image(ImageResource.line)
              .resizable()
              .aspectRatio(contentMode: .fit)
              .frame(width: 60, height: 60)
              .clipShape(Circle())
          case .messages:
            Image(ImageResource.line)
              .resizable()
              .aspectRatio(contentMode: .fit)
              .frame(width: 60, height: 60)
              .clipShape(Circle())
          case .other:
            fatalError()
          }

          Text(content.name, bundle: .module)
            .font(.callout)
            .bold()
            .foregroundColor(.godBlack)
        }
      }
      .buttonStyle(HoldDownButtonStyle())
    }
  }
}

#Preview {
  Color.red
    .sheet(
      isPresented: .constant(true)
    ) {
      ProfileShareView(
        store: .init(
          initialState: ProfileShareLogic.State(),
          reducer: { ProfileShareLogic() }
        )
      )
      .presentationDetents([.fraction(0.3)])
      .presentationDragIndicator(.visible)
    }
}
