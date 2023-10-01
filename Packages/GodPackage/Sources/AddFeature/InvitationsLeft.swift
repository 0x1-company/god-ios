import ButtonStyles
import Colors
import ComposableArchitecture
import Contacts
import ContactsClient
import CupertinoMessageFeature
import SwiftUI
import SwiftUIMessage

public struct InvitationsLeftLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    var invitations: [CNContact] = []
    @PresentationState var message: CupertinoMessageLogic.State?
  }

  public enum Action: Equatable {
    case onTask
    case contactResponse(TaskResult<CNContact>)
    case inviteButtonTapped
    case message(PresentationAction<CupertinoMessageLogic.Action>)
  }

  @Dependency(\.contacts.authorizationStatus) var authorizationStatus
  @Dependency(\.contacts.enumerateContacts) var enumerateContacts

  enum Cancel {
    case enumerateContacts
  }

  public var body: some Reducer<State, Action> {
    Reduce<State, Action> { state, action in
      switch action {
      case .onTask:
        guard case .authorized = authorizationStatus(.contacts)
        else { return .none }
        let request = CNContactFetchRequest(keysToFetch: [
          CNContactGivenNameKey as CNKeyDescriptor,
          CNContactFamilyNameKey as CNKeyDescriptor,
          CNContactImageDataKey as CNKeyDescriptor,
        ])
        return .run(priority: .background) { send in
          for try await (contact, _) in enumerateContacts(request) {
            await send(.contactResponse(.success(contact)))
          }
        } catch: { error, send in
          await send(.contactResponse(.failure(error)))
        }
        .cancellable(id: Cancel.enumerateContacts)

      case let .contactResponse(.success(contact)):
        state.invitations.append(contact)
        return .none

      case .contactResponse(.failure):
        return .none

      case .inviteButtonTapped:
        guard MessageComposeView.canSendText()
        else { return .none }
        state.message = .init(
          recipient: "+1-111-111-1112",
          body: """
          https://godapp.jp/add/tomokisun

          Get this app
          """
        )
        return .none

      case .message(.dismiss):
        state.message = nil
        return .none

      case .message:
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
            viewStore.send(.inviteButtonTapped)
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
