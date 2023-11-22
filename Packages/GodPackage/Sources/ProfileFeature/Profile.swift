import AnalyticsClient
import ComposableArchitecture
import God
import GodClient
import ProfileEditFeature
import ProfileShareFeature
import ShopFeature
import Styleguide
import SwiftUI
import UIPasteboardClient

@Reducer
public struct ProfileLogic {
  public init() {}

  public struct State: Equatable {
    @PresentationState var destination: Destination.State?
    var profile: God.CurrentUserProfileQuery.Data?
    public init() {}
  }

  public enum Action {
    case onTask
    case onAppear
    case editProfileButtonTapped
    case shareProfileButtonTapped
    case shopButtonTapped
    case invitationCodeCopyButtonTapped
    case friendButtonTapped(userId: String)
    case friendEmptyButtonTapped
    case profileResponse(TaskResult<God.CurrentUserProfileQuery.Data>)
    case destination(PresentationAction<Destination.Action>)
  }

  @Dependency(\.analytics) var analytics
  @Dependency(\.godClient) var godClient
  @Dependency(\.pasteboard) var pasteboard

  enum Cancel {
    case profile
  }

  public var body: some Reducer<State, Action> {
    Reduce<State, Action> { state, action in
      switch action {
      case .onTask:
        return .run { send in
          await withTaskCancellation(id: Cancel.profile, cancelInFlight: true) {
            await currentUserRequest(send: send)
          }
        }

      case .onAppear:
        analytics.logScreen(screenName: "Profile", of: self)
        return .none

      case .editProfileButtonTapped:
        analytics.buttonClick(name: .editProfile)
        state.destination = .profileEdit()
        return .none

      case .shareProfileButtonTapped:
        state.destination = .profileShare()
        analytics.buttonClick(
          name: .shareProfile,
          parameters: ["title": String(localized: "Share Profile", bundle: .module)]
        )
        return .none

      case .shopButtonTapped:
        analytics.buttonClick(name: .shop)
        state.destination = .shop()
        return .none

      case .invitationCodeCopyButtonTapped:
        guard let code = state.profile?.invitationCode.code
        else { return .none }

        state.destination = .alert(
          AlertState {
            TextState("Copied the invitation code.", bundle: .module)
          } actions: {
            ButtonState(action: .confirmOkay) {
              TextState("OK", bundle: .module)
            }
          }
        )
        return .run { _ in
          analytics.buttonClick(name: .invitationCodeCopy)
          pasteboard.string(code)
        }

      case let .friendButtonTapped(userId):
        state.destination = .external(.init(userId: userId))
        return .none

      case .friendEmptyButtonTapped:
        state.destination = .profileShare()
        analytics.buttonClick(
          name: .addFriends,
          parameters: ["title": String(localized: "Add Friends", bundle: .module)]
        )
        return .none

      case let .profileResponse(.success(data)):
        state.profile = data
        analytics.setUserProperty(key: .schoolId, value: data.currentUser.schoolId)
        analytics.setUserId(data.currentUser.id)
        return .none
      case .profileResponse(.failure):
        state.profile = nil
        return .none

      case .destination(.presented(.profileEdit(.delegate(.changed)))):
        return .run { send in
          await withTaskCancellation(id: Cancel.profile, cancelInFlight: true) {
            await currentUserRequest(send: send)
          }
        }

      case .destination(.presented(.alert(.confirmOkay))):
        state.destination = nil
        return .none

      case .destination(.dismiss):
        state.destination = nil
        return .none

      case .destination:
        return .none
      }
    }
    .ifLet(\.$destination, action: \.destination) {
      Destination()
    }
  }

  func currentUserRequest(send: Send<Action>) async {
    do {
      for try await data in godClient.currentUserProfile() {
        await send(.profileResponse(.success(data)))
      }
    } catch {
      await send(.profileResponse(.failure(error)))
    }
  }

  @Reducer
  public struct Destination {
    public enum State: Equatable {
      case profileEdit(ProfileEditLogic.State = .init())
      case shop(ShopLogic.State = .init())
      case profileShare(ProfileShareLogic.State = .init())
      case external(ProfileExternalLogic.State)
      case alert(AlertState<Action.Alert>)
    }

    public enum Action {
      case profileEdit(ProfileEditLogic.Action)
      case shop(ShopLogic.Action)
      case profileShare(ProfileShareLogic.Action)
      case external(ProfileExternalLogic.Action)
      case alert(Alert)

      public enum Alert: Equatable {
        case confirmOkay
      }
    }

    public var body: some Reducer<State, Action> {
      Scope(state: \.profileEdit, action: \.profileEdit) {
        ProfileEditLogic()
      }
      Scope(state: \.shop, action: \.shop) {
        ShopLogic()
      }
      Scope(state: \.profileShare, action: \.profileShare) {
        ProfileShareLogic()
      }
      Scope(state: \.external, action: \.external) {
        ProfileExternalLogic()
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
          if let data = viewStore.profile {
            ProfileSection(
              imageURL: data.currentUser.imageURL,
              friendsCount: data.currentUser.friendsCount ?? 0,
              votedCount: data.currentUser.votedCount,
              username: data.currentUser.username ?? "",
              firstName: data.currentUser.firstName,
              lastName: data.currentUser.lastName,
              displayName: data.currentUser.displayName.ja,
              schoolShortName: data.currentUser.school?.shortName,
              grade: data.currentUser.grade
            ) {
              store.send(.editProfileButtonTapped)
            }

            Divider()

            InviteSection(
              coinBalance: data.currentUser.wallet?.coinBalance ?? 0,
              code: data.invitationCode.code,
              codeCopyAction: {
                store.send(.invitationCodeCopyButtonTapped)
              },
              inviteFriendAction: {
                store.send(.shareProfileButtonTapped)
              },
              shopAction: {
                store.send(.shopButtonTapped)
              }
            )

            Divider()

            if !data.questionsOrderByVotedDesc.isEmpty {
              TopStarsSection(
                questions: data.questionsOrderByVotedDesc
              )
              .padding(.bottom, 16)
            }

            FriendsSection(
              friends: data.friends.map(\.fragments.friendFragment),
              emptyAction: {
                store.send(.friendEmptyButtonTapped)
              },
              action: { user in
                store.send(.friendButtonTapped(userId: user.id))
              }
            )
          }
        }
        .background(Color.godBackgroundWhite)
      }
      .listStyle(.plain)
      .navigationTitle(Text("Profile", bundle: .module))
      .navigationBarTitleDisplayMode(.inline)
      .task { await store.send(.onTask).finish() }
      .onAppear { store.send(.onAppear) }
      .alert(
        store: store.scope(state: \.$destination, action: ProfileLogic.Action.destination),
        state: /ProfileLogic.Destination.State.alert,
        action: ProfileLogic.Destination.Action.alert
      )
      .sheet(
        store: store.scope(state: \.$destination, action: ProfileLogic.Action.destination),
        state: /ProfileLogic.Destination.State.profileEdit,
        action: ProfileLogic.Destination.Action.profileEdit
      ) { store in
        NavigationStack {
          ProfileEditView(store: store)
        }
        .interactiveDismissDisabled()
      }
      .sheet(
        store: store.scope(state: \.$destination, action: ProfileLogic.Action.destination),
        state: /ProfileLogic.Destination.State.shop,
        action: ProfileLogic.Destination.Action.shop
      ) { store in
        NavigationStack {
          ShopView(store: store)
        }
      }
      .sheet(
        store: store.scope(state: \.$destination, action: ProfileLogic.Action.destination),
        state: /ProfileLogic.Destination.State.profileShare,
        action: ProfileLogic.Destination.Action.profileShare
      ) { store in
        ProfileShareView(store: store)
          .presentationBackground(Color.clear)
      }
      .sheet(
        store: store.scope(state: \.$destination, action: ProfileLogic.Action.destination),
        state: /ProfileLogic.Destination.State.external,
        action: ProfileLogic.Destination.Action.external
      ) { store in
        NavigationStack {
          ProfileExternalView(store: store)
        }
      }
    }
  }
}

#Preview {
  ProfileView(
    store: .init(
      initialState: ProfileLogic.State(),
      reducer: { ProfileLogic() }
    )
  )
}
