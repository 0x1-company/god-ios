import Colors
import ComposableArchitecture
import ProfileEditFeature
import God
import GodClient
import SwiftUI
import ShopFeature

public struct ProfileLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    @PresentationState var destination: Destination.State?
    var currentUser: God.CurrentUserQuery.Data.CurrentUser?
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

      case .editProfileButtonTapped:
        state.destination = .profileEdit()
        return .none
        
      case .shareProfileButtonTapped:
        return .none
        
      case .shopButtonTapped:
        state.destination = .shop()
        return .none
        
      case let .currentUserResponse(.success(data)):
        state.currentUser = data.currentUser
        return .none

      case let .currentUserResponse(.failure(error)):
        print(error)
        state.currentUser = nil
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
    }

    public enum Action: Equatable {
      case profileEdit(ProfileEditLogic.Action)
      case shop(ShopLogic.Action)
    }

    public var body: some Reducer<State, Action> {
      Scope(state: /State.profileEdit, action: /Action.profileEdit) {
        ProfileEditLogic()
      }
      Scope(state: /State.shop, action: /Action.shop) {
        ShopLogic()
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
          VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 16) {
              Color.green
                .frame(width: 90, height: 90)
                .clipShape(Circle())

              VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 16) {
                  Text("2 ")
                    .bold()
                    .foregroundColor(.primary)
                    +
                    Text("friends")
                    .foregroundColor(.secondary)

                  Text("7 ")
                    .bold()
                    .foregroundColor(.primary)
                    +
                    Text("flames")
                    .foregroundColor(.secondary)
                }

                Button("Edit Profile") {
                  viewStore.send(.editProfileButtonTapped)
                }
                .bold()
                .foregroundColor(.secondary)
                .frame(width: 120, height: 32)
                .overlay(
                  RoundedRectangle(cornerRadius: 32 / 2)
                    .stroke(Color.secondary, lineWidth: 1)
                )
              }
            }
            VStack(alignment: .leading, spacing: 4) {
              Text("Tomoki Tsukiyama")
                .bold()

              Text("@tomokisun")
            }
            HStack(spacing: 16) {
              HStack(spacing: 4) {
                Image(systemName: "house.fill")
                Text("LVAA")
              }
              HStack(spacing: 4) {
                Image(systemName: "graduationcap.fill")
                Text("9th Grade")
              }
            }
            .foregroundColor(.secondary)
          }
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(.horizontal, 16)
          .padding(.bottom, 16)
          .background(Color.godWhite)

          Divider()

          shareButtonAndCoinsSection

          Divider()

          topFlamesSection
            .padding(.bottom, 16)
          friendsSection
        }.background(Color.godBackgroundWhite)
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
    }
  }

  private var shareButtonAndCoinsSection: some View {
    HStack(spacing: 16) {
      Button {
        store.send(.shareProfileButtonTapped)
      } label: {
        HStack(spacing: 8) {
          Text("Share Profile")
            .bold()
          Image(systemName: "square.and.arrow.up")
        }
        .foregroundColor(.secondary)
        .frame(height: 52)
        .frame(maxWidth: .infinity)
      }
      .overlay(
        RoundedRectangle(cornerRadius: 52 / 2)
          .stroke(Color.secondary, lineWidth: 1)
      )
      
      Button {
        store.send(.shopButtonTapped)
      } label: {
        Text("Shop")
          .bold()
          .foregroundColor(.secondary)
          .frame(height: 52)
          .frame(maxWidth: .infinity)
      }
      .overlay(
        RoundedRectangle(cornerRadius: 52 / 2)
          .stroke(Color.secondary, lineWidth: 1)
      )
    }
    .frame(height: 84)
    .padding(.horizontal, 16)
  }

  private static let mockTopFlames: [(rank: Int, questionText: String)] = [
    (1, "Would give them your last hair tie and they’d actually give it back"),
    (2, "Always late but worth the wait"),
    (3, "Never saw a line they didn’t want to cut in front of"),
  ]

  private var topFlamesSection: some View {
    VStack(alignment: .leading, spacing: 0) {
      Text("Top Flames")
        .font(.headline)
        .bold()
        .frame(height: 32)
        .padding(.horizontal, 16)
      Divider()
      // TODO: ForEach
      ForEach(Self.mockTopFlames, id: \.rank) { flame in
        HStack(alignment: .center, spacing: 12) {
          RoundedRectangle(cornerRadius: 4)
            .fill(Color.blue)
            .frame(width: 60, height: 60)
            .overlay(
              Circle()
                .fill(Color.red)
                .frame(width: 20, height: 20),
              alignment: .bottomLeading
            )

          Text(flame.questionText)
            .font(.body)
            .multilineTextAlignment(.leading)
            .lineLimit(2)
        }
        .frame(height: 84)
        .padding(.horizontal, 16)
        Divider()
      }
    }.background(Color.godWhite)
  }

  private static let mockFriends: [String] = [
    "Satoya Hatanaka",
    "Tomoki Tsukiyama",
    "Kota Hibino",
  ]
  private var friendsSection: some View {
    VStack(alignment: .leading, spacing: 0) {
      Divider()
      Text("Friends")
        .font(.headline)
        .bold()
        .frame(height: 32)
        .padding(.horizontal, 16)
      Divider()
      // TODO: ForEach
      ForEach(Self.mockFriends, id: \.self) { friendName in
        HStack(alignment: .center, spacing: 12) {
          Circle()
            .fill(Color.blue)
            .frame(width: 48, height: 48)

          Text(friendName)
            .font(.body)

          Spacer()

          Button(action: {}, label: {
            Text("ADDED")
              .font(.body)
              .bold()
              .foregroundColor(Color.godTextSecondaryLight)
              .frame(height: 32)
              .padding(.horizontal, 12)
              .overlay(
                RoundedRectangle(cornerRadius: 14)
                  .stroke(Color.godTextSecondaryLight, lineWidth: 1)
              )
          })
        }
        .frame(height: 84)
        .padding(.horizontal, 16)
        Divider()
      }
    }.background(Color.godWhite)
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
