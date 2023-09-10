import ButtonStyles
import Colors
import ComposableArchitecture
import Contacts
import ContactsClient
import SwiftUI

public struct InvitationsLeftLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    var invitations: IdentifiedArrayOf<InvitationCardLogic.State> = []
    public init() {}
  }

  public enum Action: Equatable {
    case onTask
    case contactResponse(TaskResult<CNContact>)
    case invitations(id: InvitationCardLogic.State.ID, action: InvitationCardLogic.Action)
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
        if state.invitations.count >= 10 {
          Task.cancel(id: Cancel.enumerateContacts)
          return .none
        }
        state.invitations.insert(
          InvitationCardLogic.State(
            id: contact.identifier,
            familyName: contact.familyName,
            givenName: contact.givenName
          ),
          at: 0
        )
        return .none

      case let .contactResponse(.failure(error)):
        print(error)
        return .none

      case .invitations:
        return .none
      }
    }
    .forEach(\.invitations, action: /Action.invitations) {
      InvitationCardLogic()
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

        ForEachStore(
          store.scope(state: \.invitations, action: InvitationsLeftLogic.Action.invitations),
          content: InvitationCardView.init(store:)
        )
      }
      .task { await viewStore.send(.onTask).finish() }
    }
  }
}

struct InvitationsLeftViewPreviews: PreviewProvider {
  static var previews: some View {
    InvitationsLeftView(
      store: .init(
        initialState: InvitationsLeftLogic.State(),
        reducer: { InvitationsLeftLogic() }
      )
    )
    .previewLayout(.sizeThatFits)
  }
}
