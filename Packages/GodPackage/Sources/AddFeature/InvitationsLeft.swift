import ButtonStyles
import Colors
import ComposableArchitecture
import Contacts
import ContactsClient
import CupertinoMessageFeature
import SwiftUI
import SwiftUIMessage
import God
import GodClient

public struct InvitationsLeftLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    var currentUser: God.CurrentUserQuery.Data.CurrentUser?
    var invitations: [CNContact] = []
    @PresentationState var message: CupertinoMessageLogic.State?
  }

  public enum Action: Equatable {
    case onTask
    case inviteButtonTapped(CNContact)
    case contactResponse(TaskResult<CNContact>)
    case currentUserResponse(TaskResult<God.CurrentUserQuery.Data>)
    case message(PresentationAction<CupertinoMessageLogic.Action>)
  }

  @Dependency(\.godClient) var godClient
  @Dependency(\.contacts.authorizationStatus) var authorizationStatus
  @Dependency(\.contacts.enumerateContacts) var enumerateContacts

  public var body: some Reducer<State, Action> {
    Reduce<State, Action> { state, action in
      switch action {
      case .onTask:
        let request = CNContactFetchRequest(keysToFetch: [
          CNContactGivenNameKey as CNKeyDescriptor,
          CNContactFamilyNameKey as CNKeyDescriptor,
          CNContactImageDataKey as CNKeyDescriptor,
          CNContactPhoneNumbersKey as CNKeyDescriptor,
        ])
        return .merge(
          .run { send in
            for try await data in godClient.currentUser() {
              await send(.currentUserResponse(.success(data)))
            }
          } catch: { error, send in
            await send(.currentUserResponse(.failure(error)))
          },
          .run(priority: .background) { send in
            for try await (contact, _) in enumerateContacts(request) {
              await send(.contactResponse(.success(contact)))
            }
          } catch: { error, send in
            await send(.contactResponse(.failure(error)))
          }
        )
      case let .inviteButtonTapped(contact):
        guard
          MessageComposeView.canSendText(),
          let phoneNumber = contact.phoneNumbers.first?.value.stringValue,
          let username = state.currentUser?.username,
          let schoolName = state.currentUser?.school?.name
        else { return .none }
        state.message = .init(
          recipient: phoneNumber,
          body: """
          \(schoolName)向けの新しいアプリダウンロードしてみて！
          https://godapp.jp/add/\(username)
          """
        )
        return .none
        
      case let .contactResponse(.success(contact)):
        state.invitations.append(contact)
        return .none
        
      case let .currentUserResponse(.success(data)):
        state.currentUser = data.currentUser
        return .none

      case .message(.dismiss):
        state.message = nil
        return .none

      default:
        return .none
      }
    }
    .ifLet(\.$message, action: /Action.message) {
      CupertinoMessageLogic()
    }
  }
}

public struct InvitationsLeftView: View {
  let store: StoreOf<InvitationsLeftLogic>

  public init(store: StoreOf<InvitationsLeftLogic>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      VStack(spacing: 0) {
        FriendHeader(title: "INVITATIONS LEFT")
        ForEach(viewStore.invitations, id: \.identifier) { contact in
          InvitationCardView(
            familyName: contact.familyName,
            givenName: contact.givenName,
            imageData: contact.imageData
          ) {
            store.send(.inviteButtonTapped(contact))
          }
        }
      }
      .task { await store.send(.onTask).finish() }
      .sheet(
        store: store.scope(state: \.$message, action: { .message($0) }),
        content: CupertinoMessageView.init
      )
    }
  }
}

#Preview {
  InvitationsLeftView(
    store: .init(
      initialState: InvitationsLeftLogic.State(),
      reducer: { InvitationsLeftLogic() }
    )
  )
}
