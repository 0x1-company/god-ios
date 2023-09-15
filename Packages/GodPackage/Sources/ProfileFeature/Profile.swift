import AsyncValue
import Colors
import ComposableArchitecture
import God
import GodClient
import ProfileEditFeature
import ProfileShareFeature
import ShopFeature
import SwiftUI

public struct ProfileLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    @PresentationState var destination: Destination.State?
    var user = AsyncValue<God.CurrentUserQuery.Data.CurrentUser>.none
    public init() {}
  }

  public enum Action: Equatable {
    case onTask
    case editProfileButtonTapped
    case shareProfileButtonTapped
    case shopButtonTapped
    case currentUserResponse(TaskResult<God.CurrentUserQuery.Data>)
    case destination(PresentationAction<Destination.Action>)
  }

  @Dependency(\.godClient) var godClient

  public var body: some Reducer<State, Action> {
    Reduce<State, Action> { state, action in
      switch action {
      case .onTask:
        enum Cancel { case id }
        state.user = .loading
        return .run { send in
          for try await data in godClient.currentUser() {
            await send(.currentUserResponse(.success(data)))
          }
        } catch: { error, send in
          await send(.currentUserResponse(.failure(error)))
        }
        .cancellable(id: Cancel.id)

      case .editProfileButtonTapped:
        state.destination = .profileEdit()
        return .none

      case .shareProfileButtonTapped:
        state.destination = .profileShare()
        return .none

      case .shopButtonTapped:
        state.destination = .shop()
        return .none

      case let .currentUserResponse(.success(data)):
        state.user = .success(data.currentUser)
        return .none

      case let .currentUserResponse(.failure(error)):
        print(error)
        state.user = .none
        return .none

      case .destination(.dismiss):
        state.destination = nil
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
      case profileEdit(ProfileEditLogic.State = .init())
      case shop(ShopLogic.State = .init())
      case profileShare(ProfileShareLogic.State = .init())
    }

    public enum Action: Equatable {
      case profileEdit(ProfileEditLogic.Action)
      case shop(ShopLogic.Action)
      case profileShare(ProfileShareLogic.Action)
    }

    public var body: some Reducer<State, Action> {
      Scope(state: /State.profileEdit, action: /Action.profileEdit) {
        ProfileEditLogic()
      }
      Scope(state: /State.shop, action: /Action.shop) {
        ShopLogic()
      }
      Scope(state: /State.profileShare, action: /Action.profileShare) {
        ProfileShareLogic()
      }
    }
  }
}

public struct ProfileView: View {
  let store: StoreOf<ProfileLogic>

  public init(store: StoreOf<ProfileLogic>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      ScrollView {
        LazyVStack(alignment: .leading, spacing: 0) {
          if case let .success(user) = viewStore.user {
            ProfileSection(
              user: user.fragments.profileSectionFragment,
              editProfile: {
                store.send(.editProfileButtonTapped)
              }
            )
          }
          Divider()

          ShareShopSection(
            shareAction: {
              viewStore.send(.shareProfileButtonTapped)
            },
            shopAction: {
              viewStore.send(.shopButtonTapped)
            }
          )

          Divider()

          TopStarsSection()
            .padding(.bottom, 16)

          FriendsSection()
        }
        .background(Color.godBackgroundWhite)
      }
      .listStyle(.plain)
      .navigationTitle("Profile")
      .navigationBarTitleDisplayMode(.inline)
      .task { await viewStore.send(.onTask).finish() }
      .fullScreenCover(
        store: store.scope(state: \.$destination, action: { .destination($0) }),
        state: /ProfileLogic.Destination.State.profileEdit,
        action: ProfileLogic.Destination.Action.profileEdit
      ) { store in
        NavigationStack {
          ProfileEditView(store: store)
        }
      }
      .sheet(
        store: store.scope(state: \.$destination, action: { .destination($0) }),
        state: /ProfileLogic.Destination.State.shop,
        action: ProfileLogic.Destination.Action.shop
      ) { store in
        NavigationStack {
          ShopView(store: store)
        }
      }
      .sheet(
        store: store.scope(state: \.$destination, action: { .destination($0) }),
        state: /ProfileLogic.Destination.State.profileShare,
        action: ProfileLogic.Destination.Action.profileShare
      ) { store in
        ProfileShareView(store: store)
          .presentationDetents([.height(ProfileShareView.heightForPresentationDetents)])
          .presentationCornerRadiusIfPossible(24)
      }
    }
  }
}

extension View {
  @ViewBuilder
  func presentationCornerRadiusIfPossible(_ cornerRadius: CGFloat) -> some View {
    if #available(iOS 16.4, *) {
      self.presentationCornerRadius(cornerRadius)
    } else {
      self
    }
  }
}

struct ProfileViewPreviews: PreviewProvider {
  static var previews: some View {
    ProfileView(
      store: .init(
        initialState: ProfileLogic.State(),
        reducer: { ProfileLogic() }
      )
    )
  }
}
