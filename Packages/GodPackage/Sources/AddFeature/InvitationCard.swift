import ButtonStyles
import Colors
import ComposableArchitecture
import SwiftUI

public struct InvitationCardLogic: Reducer {
  public init() {}

  public struct State: Equatable, Identifiable {
    public var id: String
    var familyName: String
    var givenName: String

    public init(id: String, familyName: String, givenName: String) {
      self.id = id
      self.familyName = familyName
      self.givenName = givenName
    }
  }

  public enum Action: Equatable {
    case inviteButtonTapped
  }

  public var body: some Reducer<State, Action> {
    Reduce<State, Action> { _, action in
      switch action {
      case .inviteButtonTapped:
        return .none
      }
    }
  }
}

public struct InvitationCardView: View {
  let store: StoreOf<InvitationCardLogic>

  public init(store: StoreOf<InvitationCardLogic>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      HStack(spacing: 16) {
        Color.red
          .frame(width: 42, height: 42)
          .clipShape(Circle())

        VStack(alignment: .leading, spacing: 4) {
          Text("\(viewStore.familyName) \(viewStore.givenName)", bundle: .module)
          Text("29 friends on God", bundle: .module)
        }
        .frame(maxWidth: .infinity, alignment: .leading)

        Button {} label: {
          Text("INVITE", bundle: .module)
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
}
