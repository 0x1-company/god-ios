import AnimationDisableTransaction
import Colors
import ComposableArchitecture
import SwiftUI

public struct ProfileShareLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    public enum ShareContent {
      case instagram
      case line
      case messages
      case copyLink

      public var name: String {
        switch self {
        case .instagram: return "Instagram"
        case .line: return "LINE"
        case .messages: return "Messages"
        case .copyLink: return "Copy Link"
        }
      }

      public var iconImageName: String {
        switch self {
        case .instagram: return "instagram"
        case .line: return "line"
        case .messages: return "messages"
        case .copyLink: return "copylink"
        }
      }
    }

    @PresentationState var destination: Destination.State?
    var shareContents: [ShareContent] = [.instagram, .line, .messages, .copyLink]
    public init() {}
  }

  public enum Action: Equatable {
    case onTask
    case shareContentButtonTapped(State.ShareContent)
    case closeButtonTapped
    case destination(PresentationAction<Destination.Action>)
  }

  @Dependency(\.dismiss) var dismiss

  public var body: some Reducer<State, Action> {
    Reduce<State, Action> { state, action in
      switch action {
      case .onTask:
        return .none

      case let .shareContentButtonTapped(shareContent):
        switch shareContent {
        case .instagram:
          state.destination = .shareProfileToInstagramPopup()

        case .line: break
        case .messages: break
        case .copyLink:
          UIPasteboard.general.string = ""
        }
        return .none

      case .closeButtonTapped:
        return .run { _ in
          await dismiss()
        }

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

        HStack {
          Spacer()
          ForEach(viewStore.shareContents, id: \.self) { content in
            Button(action: {
              var transaction = Transaction()
              transaction.disablesAnimations = true
              viewStore.send(.shareContentButtonTapped(content), transaction: transaction)
            }) {
              VStack(spacing: 12) {
                Image(content.iconImageName, bundle: .module)
                  .resizable()
                  .aspectRatio(contentMode: .fit)
                  .frame(width: 60, height: 60)
                  .clipShape(Circle())

                Text(content.name)
                  .font(.callout)
                  .foregroundColor(.godBlack)
              }
            }
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
        }
        .overlay(
          RoundedRectangle(cornerRadius: 52 / 2)
            .stroke(Color.primary, lineWidth: 1)
        )
      }
      .padding(.top, 16)
      .padding(.horizontal, 16)
      .task { await viewStore.send(.onTask).finish() }
      .fullScreenCover(
        store: store.scope(state: \.$destination, action: { .destination($0) }),
        state: /ProfileShareLogic.Destination.State.shareProfileToInstagramPopup,
        action: ProfileShareLogic.Destination.Action.shareProfileToInstagramPopup
      ) { store in
        ShareProfileToInstagramPopupView(store: store)
          .backgroundClearSheet()
          .transaction { transaction in
            transaction.disablesAnimations = true
          }
      }
    }
  }
}

struct ProfileShareViewPreviews: PreviewProvider {
  static var previews: some View {
    Text("ProfileShare")
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
}
