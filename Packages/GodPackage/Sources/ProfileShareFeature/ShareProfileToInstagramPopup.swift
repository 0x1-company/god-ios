import AnimationDisableTransaction
import Colors
import ComposableArchitecture
import God
import GodClient
import SwiftUI

public struct ShareProfileToInstagramPopupLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    var currentPage: Page.State = .profileShareToInstagram()
    public init() {}
  }

  public enum Action: Equatable {
    case closeButtonTapped
    case page(Page.Action)
  }

  @Dependency(\.godClient) var godClient
  @Dependency(\.dismiss) var dismiss

  public var body: some Reducer<State, Action> {
    Scope(state: \.currentPage, action: /Action.page, child: Page.init)
    Reduce { state, action in
      switch action {
      case .closeButtonTapped:
        return .run { _ in
          await dismiss()
        }

      case .page(.profileShareToInstagram(.delegate(.nextPage))):
        state.currentPage = .howToShareOnInstagram()
        return .none
        
      case .page(.howToShareOnInstagram(.delegate(.showdStories))):
        state.currentPage = .profileShareToInstagram()
        return .none

      case .page:
        return .none
      }
    }
  }

  public struct Page: Reducer {
    public enum State: Equatable {
      case profileShareToInstagram(ProfileShareToInstagramLogic.State = .init())
      case howToShareOnInstagram(HowToShareOnInstagramLogic.State = .init())
    }

    public enum Action: Equatable {
      case profileShareToInstagram(ProfileShareToInstagramLogic.Action)
      case howToShareOnInstagram(HowToShareOnInstagramLogic.Action)
    }

    public var body: some Reducer<State, Action> {
      Scope(state: /State.profileShareToInstagram, action: /Action.profileShareToInstagram, child: ProfileShareToInstagramLogic.init)
      Scope(state: /State.howToShareOnInstagram, action: /Action.howToShareOnInstagram, child: HowToShareOnInstagramLogic.init)
    }
  }
}

public struct ShareProfileToInstagramPopupView: View {
  public static let heightForPresentationDetents: CGFloat = 260
  let store: StoreOf<ShareProfileToInstagramPopupLogic>

  public init(store: StoreOf<ShareProfileToInstagramPopupLogic>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      ZStack(alignment: .center) {
        Color.godBlack.opacity(0.6)
          .overlay(alignment: .topTrailing) {
            Button {
              viewStore.send(.closeButtonTapped)
            } label: {
              Image(systemName: "xmark")
                .resizable()
                .frame(width: 16, height: 16)
                .foregroundColor(Color.white)
            }
            .offset(x: -24, y: 60)
          }

        SwitchStore(
          store.scope(
            state: \.currentPage,
            action: ShareProfileToInstagramPopupLogic.Action.page
          )
        ) { store in
          switch store {
          case .profileShareToInstagram:
            CaseLet(
              /ShareProfileToInstagramPopupLogic.Page.State.profileShareToInstagram,
              action: ShareProfileToInstagramPopupLogic.Page.Action.profileShareToInstagram,
              then: ProfileShareToInstagramView.init(store:)
            )
          case .howToShareOnInstagram:
            CaseLet(
              /ShareProfileToInstagramPopupLogic.Page.State.howToShareOnInstagram,
              action: ShareProfileToInstagramPopupLogic.Page.Action.howToShareOnInstagram,
              then: HowToShareOnInstagramView.init(store:)
            )
          }
        }
        .padding(.horizontal, 20)
      }
      .edgesIgnoringSafeArea(.all)
    }
  }
}

#Preview {
  Color.red
    .sheet(
      isPresented: .constant(true)
    ) {
      ShareProfileToInstagramPopupView(
        store: .init(
          initialState: ShareProfileToInstagramPopupLogic.State(),
          reducer: { ShareProfileToInstagramPopupLogic() }
        )
      )
      .presentationDetents([.fraction(0.3)])
      .presentationDragIndicator(.visible)
    }
}
