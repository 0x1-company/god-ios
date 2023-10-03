import AnimationDisableTransaction
import BackgroundClearSheet
import ButtonStyles
import Colors
import ComposableArchitecture
import God
import GodClient
import SwiftUI

public struct ProfileShareLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    var currentUser: God.CurrentUserQuery.Data.CurrentUser?
    @PresentationState var destination: Destination.State?
    public init() {}
  }

  public enum Action: Equatable {
    case onTask
    case contentButtonTapped(Content)
    case closeButtonTapped
    case currentUserResponse(TaskResult<God.CurrentUserQuery.Data>)
    case destination(PresentationAction<Destination.Action>)
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
        guard let username = state.currentUser?.username else { return .none }
        let text = "https://godapp.jp/add/\(username)"
        guard let url = URL(string: "https://line.me/R/share?text=\(text)")
        else { return .none }
        return .run { _ in
          await openURL(url)
        }

      case .contentButtonTapped(.messages):
        return .none

      case .contentButtonTapped(.other):
        return .none

      case .closeButtonTapped:
        return .run { _ in
          await dismiss()
        }

      case let .currentUserResponse(.success(data)):
        state.currentUser = data.currentUser
        return .none

      case .currentUserResponse(.failure):
        state.currentUser = nil
        return .none

      case .destination:
        return .none
      }
    }
    .ifLet(\.$destination, action: /Action.destination) {
      Destination()
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

    public var iconImageName: String {
      switch self {
      case .instagram: return "instagram"
      case .line: return "line"
      case .messages: return "messages"
      case .other: return "other"
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
            Button {
              store.send(.contentButtonTapped(content), transaction: .animationDisable)
            } label: {
              VStack(spacing: 12) {
                Image(content.iconImageName, bundle: .module)
                  .resizable()
                  .aspectRatio(contentMode: .fit)
                  .frame(width: 60, height: 60)
                  .clipShape(Circle())

                Text(content.name, bundle: .module)
                  .font(.callout)
                  .bold()
                  .foregroundColor(.godBlack)
              }
            }
            .buttonStyle(HoldDownButtonStyle())
            Spacer()
          }
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
