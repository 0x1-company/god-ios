import ButtonStyles
import Colors
import ComposableArchitecture
import Contacts
import ContactsClient
import SwiftUI
import SwiftUIMessage
import CupertinoMessageFeature

public struct InvitationsLeftLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    var invitations: IdentifiedArrayOf<InviteCard> = []
    @PresentationState var message: CupertinoMessageLogic.State?
    public init() {}

    public struct InviteCard: Equatable, Identifiable {
      public var id: String
      public var familyName: String
      public var givenName: String
    }
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
          State.InviteCard(
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

        ForEach(viewStore.invitations) { state in
          InvitationCardView(
            familyName: state.familyName,
            givenName: state.givenName
          ) {
            viewStore.send(.inviteButtonTapped)
          }
        }
      }
      .task { await viewStore.send(.onTask).finish() }
    }
    .sheet(
      store: store.scope(state: \.$message, action: { .message($0) }),
      content: CupertinoMessageView.init
    )
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
