import ButtonStyles
import Colors
import ComposableArchitecture
import Contacts
import ContactsClient
import SwiftUI

public struct InvitationsLeftLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    var contacts: [CNContact] = []
    public init() {}
  }

  public enum Action: Equatable {
    case onTask
    case contactResponse(TaskResult<CNContact>)
  }

  @Dependency(\.contacts.authorizationStatus) var authorizationStatus
  @Dependency(\.contacts.enumerateContacts) var enumerateContacts

  enum Cancel {
    case enumerateContacts
  }

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
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
        if state.contacts.count >= 10 {
          Task.cancel(id: Cancel.enumerateContacts)
          return .none
        }
        if state.contacts.first(where: { $0.identifier == contact.identifier }) == nil {
          state.contacts.append(contact)
        }
        return .none

      case let .contactResponse(.failure(error)):
        print(error)
        return .none
      }
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

        ForEach(viewStore.contacts, id: \.identifier) { contact in
          HStack(spacing: 16) {
            Color.red
              .frame(width: 42, height: 42)
              .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
              Text("\(contact.familyName) \(contact.givenName)")
              Text("29 friends on God")
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Button {} label: {
              Text("INVITE")
                .bold()
                .frame(width: 84, height: 34)
                .foregroundColor(.godService)
                .overlay(
                  RoundedRectangle(cornerRadius: 34 / 2)
                    .stroke(Color.godService, lineWidth: 1)
                )
            }
            .buttonStyle(HoldDownButtonStyle())
          }
          .frame(height: 76)
          .padding(.horizontal, 16)
        }
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
