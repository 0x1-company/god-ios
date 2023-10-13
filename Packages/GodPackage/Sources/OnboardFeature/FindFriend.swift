import AnalyticsClient
import Styleguide
import Styleguide
import ComposableArchitecture
import Contacts
import ContactsClient
import SwiftUI

public struct FindFriendLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    public init() {}
  }

  public enum Action: Equatable {
    case onAppear
    case findButtonTapped
    case delegate(Delegate)

    public enum Delegate: Equatable {
      case nextScreen
    }
  }

  @Dependency(\.analytics) var analytics
  @Dependency(\.contacts.requestAccess) var requestAccess

  public var body: some Reducer<State, Action> {
    Reduce<State, Action> { _, action in
      switch action {
      case .onAppear:
        analytics.logScreen(screenName: "FindFriend", of: self)
        return .none
      case .findButtonTapped:
        return .run { send in
          _ = try? await requestAccess(.contacts)
          await send(.delegate(.nextScreen))
        }

      case .delegate:
        return .none
      }
    }
  }
}

public struct FindFriendView: View {
  let store: StoreOf<FindFriendLogic>

  public init(store: StoreOf<FindFriendLogic>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      VStack(spacing: 28) {
        Spacer()

        Text("God uses your contacts\nto find friends", bundle: .module)
          .bold()
          .foregroundColor(Color.godWhite)

        Button {
          viewStore.send(.findButtonTapped)
        } label: {
          Text("Find My Friends", bundle: .module)
            .bold()
            .font(.title3)
            .frame(height: 54)
            .frame(maxWidth: .infinity)
            .foregroundColor(Color.black)
            .padding(.horizontal, 16)
            .background(Color.white)
            .clipShape(Capsule())
        }
        .padding(.horizontal, 34)
        .buttonStyle(HoldDownButtonStyle())

        Spacer()

        Text("God cares intensely about your privacy.\nWeb will never text or spam your contacts.", bundle: .module)
          .foregroundColor(Color.godWhite)
      }
      .multilineTextAlignment(.center)
      .background(Color.godService)
      .navigationBarBackButtonHidden()
      .onAppear { store.send(.onAppear) }
    }
  }
}

struct FindFriendViewPreviews: PreviewProvider {
  static var previews: some View {
    FindFriendView(
      store: .init(
        initialState: FindFriendLogic.State(),
        reducer: { FindFriendLogic() }
      )
    )
  }
}
