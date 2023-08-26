import ComposableArchitecture
import Colors
import Contacts
import ContactsClient
import ButtonStyles
import SwiftUI

public struct FindFriendReducer: Reducer {
  public init() {}

  public struct State: Equatable {
    public init() {}
  }

  public enum Action: Equatable {
    case findButtonTapped
    case delegate(Delegate)
    
    public enum Delegate: Equatable {
      case nextPhoneNumber
    }
  }
  
  @Dependency(\.contacts.requestAccess) var requestAccess

  public var body: some ReducerOf<Self> {
    Reduce { _, action in
      switch action {
      case .findButtonTapped:
        return .run { send in
          _ = try await self.requestAccess(.contacts)
          await send(.delegate(.nextPhoneNumber))
        }
        
      case .delegate:
        return .none
      }
    }
  }
}

public struct FindFriendView: View {
  let store: StoreOf<FindFriendReducer>

  public init(store: StoreOf<FindFriendReducer>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      VStack(spacing: 28) {
        Spacer()
        
        Text("God uses your contacts\nto find friends")
          .bold()
          .foregroundColor(Color.godWhite)

        Button {
          viewStore.send(.findButtonTapped)
        } label: {
          Text("Find My Friends")
            .bold()
            .font(.title3)
            .frame(height: 54)
            .frame(maxWidth: .infinity)
            .foregroundColor(Color.black)
            .overlay(alignment: .leading) {
              Image("money-mouth-face", bundle: .module)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 32, height: 32)
                .clipped()
            }
            .padding(.horizontal, 16)
            .background(Color.white)
            .clipShape(Capsule())
        }
        .padding(.horizontal, 34)
        .buttonStyle(HoldDownButtonStyle())
        
        Spacer()
        
        Text("God cares intensely about your privacy.\nWeb will never text or spam your contacts.")
          .foregroundColor(Color.godWhite)
      }
      .multilineTextAlignment(.center)
      .background(Color.godService)
    }
  }
}

struct FindFriendViewPreviews: PreviewProvider {
  static var previews: some View {
    FindFriendView(
      store: .init(
        initialState: FindFriendReducer.State(),
        reducer: { FindFriendReducer() }
      )
    )
  }
}
