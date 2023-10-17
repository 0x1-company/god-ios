import AnalyticsClient
import ComposableArchitecture
import Contacts
import ContactsClient
import CupertinoMessageFeature
import God
import GodClient
import NameImage
import ProfileImage
import Styleguide
import SwiftUI
import SwiftUIMessage

public struct AddFriendsLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    var selectUserIds: [String] = []
    var users: [God.PeopleYouMayKnowQuery.Data.UsersBySameSchool.Edge.Node] = []
    var contacts: [CNContact] = []
    @PresentationState var message: CupertinoMessageLogic.State?

    public init() {}
  }

  public enum Action: Equatable {
    case onTask
    case onAppear
    case nextButtonTapped
    case selectButtonTapped(String)
    case inviteButtonTapped(CNContact)
    case usersResponse(TaskResult<God.PeopleYouMayKnowQuery.Data>)
    case contactResponse(TaskResult<CNContact>)
    case createFriendRequest(TaskResult<God.CreateFriendRequestMutation.Data>)
    case delegate(Delegate)
    case message(PresentationAction<CupertinoMessageLogic.Action>)

    public enum Delegate: Equatable {
      case nextScreen
    }
  }

  @Dependency(\.analytics) var analytics
  @Dependency(\.godClient) var godClient
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
            for try await data in godClient.peopleYouMayKnow() {
              await send(.usersResponse(.success(data)))
            }
          }, catch: { error, send in
            await send(.usersResponse(.failure(error)))
          }),
          .run(operation: { send in
            await contactsRequest(send: send)
          })
          .cancellable(id: Cancel.contacts, cancelInFlight: true)
        )
      case .onAppear:
        analytics.logScreen(screenName: "AddFriends", of: self)
        return .none

      case .nextButtonTapped:
        return .merge(
          .run(operation: { send in
            await send(.delegate(.nextScreen))
          }),
          .run(operation: { [userIds = state.selectUserIds] send in
            for userId in userIds {
              let input = God.CreateFriendRequestInput(toUserId: userId)
              await send(.createFriendRequest(TaskResult {
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
        state.users = data.usersBySameSchool.edges.map(\.node)
        return .none

      case .usersResponse(.failure):
        state.users = []
        return .none

      case let .contactResponse(.success(contact)):
        guard
          !contact.phoneNumbers.isEmpty,
          !contact.familyName.isEmpty,
          !contact.givenName.isEmpty
        else { return .none }

        guard state.contacts.count <= 100 else {
          return Effect<Action>.cancel(id: Cancel.contacts)
        }
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

  public init(store: StoreOf<AddFriendsLogic>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      ScrollView {
        LazyVStack(spacing: 0) {
          Text("SHARE PROFILE", bundle: .module)
            .frame(height: 34)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .foregroundColor(.secondary)
            .background(Color(uiColor: .quaternarySystemFill))
            .font(.system(.body, design: .rounded, weight: .bold))
          
          Divider()

          SocialShareView(
            shareURL: URL(string: "https://godapp.jp")!,
            storyAction: {},
            lineAction: {},
            messageAction: {}
          )
          .padding(.vertical, 12)
          .padding(.horizontal, 24)
          
          Divider()
          
          Text("PEOPLE YOU MAY KNOW", bundle: .module)
            .frame(height: 34)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .foregroundColor(.secondary)
            .background(Color(uiColor: .quaternarySystemFill))
            .font(.system(.body, design: .rounded, weight: .bold))

          Divider()

          ForEach(viewStore.users, id: \.self) { user in
            Button {
              viewStore.send(.selectButtonTapped(user.id))
            } label: {
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
                  .fill(
                    viewStore.selectUserIds.contains(user.id)
                      ? Color.godService
                      : Color.white
                  )
                  .frame(width: 26, height: 26)
                  .clipShape(Circle())
                  .overlay(
                    RoundedRectangle(cornerRadius: 26 / 2)
                      .stroke(
                        viewStore.selectUserIds.contains(user.id)
                          ? Color.godService
                          : Color.godTextSecondaryLight,
                        lineWidth: 2
                      )
                  )
              }
              .padding(.horizontal, 16)
              .frame(height: 72)
              .background(Color.white)
            }

            Divider()
          }
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
                  .bold()
                  .frame(height: 34)
                  .foregroundColor(.godService)
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
      .navigationTitle(Text("Add Friends", bundle: .module))
      .navigationBarTitleDisplayMode(.inline)
      .toolbarBackground(Color.godService, for: .navigationBar)
      .toolbarBackground(.visible, for: .navigationBar)
      .toolbarColorScheme(.dark, for: .navigationBar)
      .task { await viewStore.send(.onTask).finish() }
      .onAppear { store.send(.onAppear) }
      .sheet(
        store: store.scope(state: \.$message, action: { .message($0) }),
        content: CupertinoMessageView.init
      )
      .toolbar {
        Button("Next") {
          viewStore.send(.nextButtonTapped)
        }
        .bold()
        .foregroundColor(Color.white)
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
