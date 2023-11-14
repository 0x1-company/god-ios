import AnalyticsClient
import ComposableArchitecture
import Constants
import Contacts
import ContactsClient
import CupertinoMessageFeature
import God
import GodClient
import NameImage
import ProfileImage
import ProfileStoryFeature
import ShareLinkBuilder
import SocialShare
import Styleguide
import SwiftUI
import SwiftUIMessage
import UIPasteboardClient

@Reducer
public struct AddFriendsLogic {
  public init() {}

  public struct State: Equatable {
    typealias User = God.PeopleYouMayKnowQuery.Data.UsersBySameSchool.Edge.Node
    var clubActivity: God.PeopleYouMayKnowQuery.Data.CurrentUser.ClubActivity?
    var selectUserIds: [String] = []
    var usersBySameClub: [User] = []
    var usersBySameGeneration: [User] = []
    var usersByOther: [User] = []
    var contacts: [CNContact] = []
    @PresentationState var message: CupertinoMessageLogic.State?

    var shareURL = URL(string: "https://godapp.jp")!
    var profileStoryFragment: God.ProfileStoryFragment?
    var profileImageData: Data?
    var schoolImageData: Data?

    public init() {}
  }

  public enum Action: Equatable {
    case onTask
    case onAppear
    case storyButtonTapped(UIImage?)
    case lineButtonTapped
    case messageButtonTapped
    case nextButtonTapped
    case selectButtonTapped(String)
    case inviteButtonTapped(CNContact)
    case usersResponse(TaskResult<God.PeopleYouMayKnowQuery.Data>)
    case contactResponse(TaskResult<CNContact>)
    case profileImageResponse(TaskResult<Data>)
    case schoolImageResponse(TaskResult<Data>)
    case createFriendResponse(TaskResult<God.CreateFriendRequestMutation.Data>)
    case delegate(Delegate)
    case message(PresentationAction<CupertinoMessageLogic.Action>)

    public enum Delegate: Equatable {
      case nextScreen
    }
  }

  @Dependency(\.openURL) var openURL
  @Dependency(\.analytics) var analytics
  @Dependency(\.godClient) var godClient
  @Dependency(\.urlSession) var urlSession
  @Dependency(\.pasteboard) var pasteboard
  @Dependency(\.contacts.authorizationStatus) var authorizationStatus
  @Dependency(\.contacts.enumerateContacts) var enumerateContacts

  enum Cancel {
    case contacts
  }

  public var body: some Reducer<State, Action> {
    Reduce<State, Action> { state, action in
      switch action {
      case .onTask:
        return .merge(
          .run(operation: { send in
            await peopleYouMayKnowRequest(send: send)
          }),
          .run(operation: { send in
            await contactsRequest(send: send)
          })
          .cancellable(id: Cancel.contacts, cancelInFlight: true)
        )
      case .onAppear:
        analytics.logScreen(screenName: "AddFriends", of: self)
        return .none

      case let .storyButtonTapped(.some(profileCardImage)):
        analytics.buttonClick(name: .storyShare)
        guard let imageData = profileCardImage.pngData() else {
          return .none
        }
        let pasteboardItems: [String: Any] = [
          "com.instagram.sharedSticker.stickerImage": imageData,
          "com.instagram.sharedSticker.backgroundTopColor": "#000000",
          "com.instagram.sharedSticker.backgroundBottomColor": "#000000",
        ]
        pasteboard.setItems(
          [pasteboardItems],
          [.expirationDate: Date().addingTimeInterval(300)]
        )
        return .run { _ in
          await openURL(Constants.storiesURL)
        }

      case .lineButtonTapped:
        analytics.buttonClick(name: .lineShare)
        guard let lineURL = ShareLinkBuilder.buildForLine(
          path: .add,
          username: state.profileStoryFragment?.username
        ) else { return .none }
        return .run { _ in
          await openURL(lineURL)
        }

      case .messageButtonTapped:
        analytics.buttonClick(name: .smsShare)
        let username = state.profileStoryFragment?.username
        let smsText = ShareLinkBuilder.buildShareText(path: .add, username: username, source: .sms, medium: .onboard)
        guard let smsText, MessageComposeView.canSendText()
        else { return .none }
        state.message = .init(recipients: [], body: smsText)
        return .none

      case .nextButtonTapped:
        return .merge(
          .run(operation: { send in
            await send(.delegate(.nextScreen))
          }),
          .run(operation: { [userIds = state.selectUserIds] send in
            for userId in userIds {
              let input = God.CreateFriendRequestInput(toUserId: userId)
              await send(.createFriendResponse(TaskResult {
                try await godClient.createFriendRequest(input)
              }))
            }
          })
        )

      case let .selectButtonTapped(userId):
        if state.selectUserIds.contains(userId) {
          state.selectUserIds = state.selectUserIds.filter { $0 != userId }
        } else {
          state.selectUserIds.append(userId)
        }
        return .none

      case let .inviteButtonTapped(contact):
        guard
          MessageComposeView.canSendText(),
          let phoneNumber = contact.phoneNumbers.first?.value.stringValue
        else { return .none }
        state.message = .init(
          recipient: phoneNumber,
          body: "新しいアプリダウンロードしてみて！\nhttps://godapp.jp"
        )
        return .none

      case let .usersResponse(.success(data)):
        let currentUser = data.currentUser
        let users = data.usersBySameSchool.edges.map(\.node)

        if currentUser.clubActivityId != nil {
          state.usersBySameClub = users.filter { $0.clubActivityId == currentUser.clubActivityId }
        }
        state.usersBySameGeneration = users.filter { $0.generation == currentUser.generation }
        let usersByFiltered = state.usersBySameClub + state.usersBySameGeneration
        state.usersByOther = users.filter { !usersByFiltered.contains($0) }

        state.clubActivity = currentUser.clubActivity
        state.profileStoryFragment = currentUser.fragments.profileStoryFragment
        if let username = currentUser.username {
          state.shareURL = ShareLinkBuilder.buildGodLink(path: .add, username: username, source: .share, medium: .onboard)
        }
        return .run { send in
          await withTaskGroup(of: Void.self) { group in
            if let imageURL = URL(string: currentUser.imageURL) {
              group.addTask {
                do {
                  let (data, _) = try await urlSession.data(from: imageURL)
                  await send(.profileImageResponse(.success(data)))
                } catch {
                  await send(.profileImageResponse(.failure(error)))
                }
              }
            }
            if let imageURL = URL(string: currentUser.school?.profileImageURL ?? "") {
              group.addTask {
                do {
                  let (data, _) = try await urlSession.data(from: imageURL)
                  await send(.schoolImageResponse(.success(data)))
                } catch {
                  await send(.schoolImageResponse(.failure(error)))
                }
              }
            }
          }
        }

      case let .profileImageResponse(.success(data)):
        state.profileImageData = data
        return .none

      case let .schoolImageResponse(.success(data)):
        state.schoolImageData = data
        return .none

      case let .contactResponse(.success(contact)):
        guard state.contacts.count <= 20 else {
          return .cancel(id: Cancel.contacts)
        }
        guard
          !contact.phoneNumbers.isEmpty,
          !contact.familyName.isEmpty,
          !contact.givenName.isEmpty
        else { return .none }
        state.contacts.append(contact)
        return .none

      default:
        return .none
      }
    }
    .ifLet(\.$message, action: /Action.message) {
      CupertinoMessageLogic()
    }
  }

  private func peopleYouMayKnowRequest(send: Send<Action>) async {
    do {
      for try await data in godClient.peopleYouMayKnow() {
        await send(.usersResponse(.success(data)))
      }
    } catch {
      await send(.usersResponse(.failure(error)))
    }
  }

  private func contactsRequest(send: Send<Action>) async {
    guard case .authorized = authorizationStatus(.contacts)
    else { return }
    do {
      let request = CNContactFetchRequest(keysToFetch: [
        CNContactImageDataKey as CNKeyDescriptor,
        CNContactGivenNameKey as CNKeyDescriptor,
        CNContactFamilyNameKey as CNKeyDescriptor,
        CNContactPhoneNumbersKey as CNKeyDescriptor,
      ])
      for try await (contact, _) in enumerateContacts(request) {
        await send(.contactResponse(.success(contact)))
      }
    } catch {
      await send(.contactResponse(.failure(error)))
    }
  }
}

public struct AddFriendsView: View {
  let store: StoreOf<AddFriendsLogic>
  @Environment(\.displayScale) var displayScale

  public init(store: StoreOf<AddFriendsLogic>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      let instagramStoryView = instagramStoryView(
        profileImageData: viewStore.profileImageData,
        schoolImageData: viewStore.schoolImageData,
        fragment: viewStore.profileStoryFragment
      )
      ZStack {
        instagramStoryView
        ScrollView {
          LazyVStack(spacing: 0) {
            listHeader(String(localized: "SHARE PROFILE", bundle: .module))

            Divider()

            SocialShare(
              shareURL: viewStore.shareURL,
              storyAction: {
                let renderer = ImageRenderer(content: instagramStoryView)
                renderer.scale = displayScale
                store.send(.storyButtonTapped(renderer.uiImage))
              },
              lineAction: {
                store.send(.lineButtonTapped)
              },
              messageAction: {
                store.send(.messageButtonTapped)
              }
            )
            .padding(.vertical, 12)
            .padding(.horizontal, 24)

            Divider()

            if let clubActivity = viewStore.clubActivity {
              listHeader(clubActivity.name)

              Divider()

              ForEach(viewStore.usersBySameClub, id: \.self) { user in
                UserCard(
                  user: user,
                  isSelected: viewStore.selectUserIds.contains(user.id)
                ) {
                  store.send(.selectButtonTapped(user.id))
                }
                Divider()
              }
            }

            listHeader(String(localized: "SAME GRADE", bundle: .module))

            Divider()

            ForEach(viewStore.usersBySameGeneration, id: \.self) { user in
              UserCard(
                user: user,
                isSelected: viewStore.selectUserIds.contains(user.id)
              ) {
                store.send(.selectButtonTapped(user.id))
              }
              Divider()
            }

            listHeader(String(localized: "FROM SCHOOL", bundle: .module))

            Divider()

            ForEach(viewStore.usersByOther, id: \.self) { user in
              UserCard(
                user: user,
                isSelected: viewStore.selectUserIds.contains(user.id)
              ) {
                store.send(.selectButtonTapped(user.id))
              }
              Divider()
            }

            listHeader(String(localized: "INVITE FRIENDS", bundle: .module))

            Divider()

            ForEach(viewStore.contacts, id: \.identifier) { contact in
              HStack(alignment: .center, spacing: 16) {
                if let imageData = contact.imageData, let image = UIImage(data: imageData) {
                  Image(uiImage: image)
                    .resizable()
                    .frame(width: 42, height: 42)
                    .clipShape(Circle())
                } else {
                  NameImage(name: contact.givenName, size: 42)
                }

                VStack(alignment: .leading) {
                  Text(contact.familyName + contact.givenName)
                }

                Spacer()

                Button {
                  store.send(.inviteButtonTapped(contact))
                } label: {
                  Text("INVITE", bundle: .module)
                    .font(.system(.body, design: .rounded, weight: .bold))
                    .frame(height: 34)
                    .foregroundStyle(Color.godService)
                    .padding(.horizontal, 12)
                    .overlay(
                      RoundedRectangle(cornerRadius: 34 / 2)
                        .stroke(Color.godService, lineWidth: 1)
                    )
                }
                .buttonStyle(HoldDownButtonStyle())
              }
              .padding(.horizontal, 16)
              .frame(height: 72)
              .background(Color.white)

              Divider()
            }
          }
        }
        .background(Color.white)
      }
      .navigationTitle(Text("Add Friends", bundle: .module))
      .navigationBarTitleDisplayMode(.inline)
      .toolbarBackground(Color.godService, for: .navigationBar)
      .toolbarBackground(.visible, for: .navigationBar)
      .toolbarColorScheme(.dark, for: .navigationBar)
      .task { await store.send(.onTask).finish() }
      .onAppear { store.send(.onAppear) }
      .sheet(
        store: store.scope(state: \.$message, action: { .message($0) }),
        content: CupertinoMessageView.init
      )
      .toolbar {
        Button {
          store.send(.nextButtonTapped)
        } label: {
          Text("Next", bundle: .module)
            .foregroundStyle(Color.white)
            .font(.system(.body, design: .rounded, weight: .bold))
        }
      }
    }
  }

  @ViewBuilder
  func instagramStoryView(
    profileImageData: Data?,
    schoolImageData: Data?,
    fragment: God.ProfileStoryFragment?
  ) -> some View {
    if let fragment {
      ProfileStoryView(
        profileImageData: profileImageData,
        firstName: fragment.firstName,
        displayName: fragment.displayName.ja,
        username: fragment.username,
        schoolImageData: schoolImageData,
        schoolName: fragment.school?.name
      )
    }
  }

  @ViewBuilder
  func listHeader(_ title: String) -> some View {
    Text(title)
      .frame(height: 34)
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(.horizontal, 16)
      .foregroundStyle(.secondary)
      .background(Color(uiColor: .quaternarySystemFill))
      .font(.system(.body, design: .rounded, weight: .bold))
  }

  struct UserCard: View {
    let user: AddFriendsLogic.State.User
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
      Button(action: action) {
        HStack(alignment: .center, spacing: 16) {
          ProfileImage(
            urlString: user.imageURL,
            name: user.firstName,
            size: 40
          )

          VStack(alignment: .leading) {
            Text(user.displayName.ja)
              .foregroundStyle(Color.black)
          }
          .frame(maxWidth: .infinity, alignment: .leading)

          Rectangle()
            .fill(isSelected ? Color.godService : Color.white)
            .frame(width: 26, height: 26)
            .clipShape(Circle())
            .overlay(
              RoundedRectangle(cornerRadius: 26 / 2)
                .stroke(
                  isSelected ? Color.godService : Color.godTextSecondaryLight,
                  lineWidth: 2
                )
            )
        }
        .padding(.horizontal, 16)
        .frame(height: 72)
        .background(Color.white)
      }
    }
  }
}

#Preview {
  NavigationStack {
    AddFriendsView(
      store: .init(
        initialState: AddFriendsLogic.State(),
        reducer: { AddFriendsLogic() }
      )
    )
  }
}
