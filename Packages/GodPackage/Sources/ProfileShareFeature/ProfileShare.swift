import AnalyticsClient
import AnimationDisableTransaction
import BackgroundClearSheet
import ComposableArchitecture
import CupertinoMessageFeature
import God
import GodClient
import ShareLinkBuilder
import Styleguide
import SwiftUI

@Reducer
public struct ProfileShareLogic {
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

  public enum Action {
    case onTask
    case onAppear
    case contentButtonTapped(Content)
    case closeButtonTapped
    case currentUserResponse(TaskResult<God.CurrentUserQuery.Data>)
    case destination(PresentationAction<Destination.Action>)
    case message(PresentationAction<CupertinoMessageLogic.Action>)
  }

  @Dependency(\.dismiss) var dismiss
  @Dependency(\.openURL) var openURL
  @Dependency(\.godClient) var godClient
  @Dependency(\.analytics) var analytics

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

      case .onAppear:
        analytics.logScreen(screenName: "ProfileShare", of: self)
        return .none

      case .contentButtonTapped(.instagram):
        analytics.buttonClick(name: .storyShare)
        state.destination = .shareProfileToInstagramPopup()
        return .none

      case .contentButtonTapped(.line):
        analytics.buttonClick(name: .lineShare)
        return .run { [url = state.lineURL] _ in
          await openURL(url)
        }

      case .contentButtonTapped(.messages):
        analytics.buttonClick(name: .smsShare)
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
    .ifLet(\.$destination, action: \.destination) {
      Destination()
    }
    .ifLet(\.$message, action: \.message) {
      CupertinoMessageLogic()
    }
  }

  @Reducer
  public struct Destination {
    public enum State: Equatable {
      case shareProfileToInstagramPopup(ShareProfileToInstagramPopupLogic.State = .init())
    }

    public enum Action {
      case shareProfileToInstagramPopup(ShareProfileToInstagramPopupLogic.Action)
    }

    public var body: some Reducer<State, Action> {
      Scope(state: \.shareProfileToInstagramPopup, action: \.shareProfileToInstagramPopup) {
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
      VStack(spacing: 0) {
        Color.clear
          .contentShape(Rectangle())
          .onTapGesture {
            store.send(.closeButtonTapped)
          }

        VStack(alignment: .center, spacing: 28) {
          Text("Share Profile", bundle: .module)
            .font(.system(.title3, design: .rounded, weight: .bold))

          HStack {
            Spacer()
            ForEach(ProfileShareLogic.Content.allCases, id: \.self) { content in
              switch content {
              case .instagram, .line:
                ShareButton(content: content) {
                  store.send(.contentButtonTapped(content), transaction: .animationDisable)
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
                      .foregroundStyle(Color.godBlack)
                      .font(.system(.callout, design: .rounded, weight: .bold))
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
                      .foregroundStyle(Color.godBlack)
                      .font(.system(.callout, design: .rounded, weight: .bold))
                  }
                }
              }
              Spacer()
            }
          }

          Button {
            store.send(.closeButtonTapped)
          } label: {
            Text("Close", bundle: .module)
              .font(.system(.body, design: .rounded, weight: .bold))
              .frame(height: 52)
              .frame(maxWidth: .infinity)
              .foregroundStyle(.black)
              .overlay(
                RoundedRectangle(cornerRadius: 52 / 2)
                  .stroke(Color.primary, lineWidth: 1)
              )
          }
        }
        .padding(.top, 24)
        .padding(.horizontal, 16)
        .background(Color.white)
        .buttonStyle(HoldDownButtonStyle())
      }
      .task { await store.send(.onTask).finish() }
      .onAppear { store.send(.onAppear) }
      .sheet(
        store: store.scope(state: \.$message, action: \.message),
        content: CupertinoMessageView.init
      )
      .fullScreenCover(
        store: store.scope(
          state: \.$destination.shareProfileToInstagramPopup,
          action: \.destination.shareProfileToInstagramPopup
        )
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
            .font(.system(.callout, design: .rounded, weight: .bold))
            .foregroundStyle(Color.godBlack)
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
      .presentationBackground(Color.clear)
    }
}
