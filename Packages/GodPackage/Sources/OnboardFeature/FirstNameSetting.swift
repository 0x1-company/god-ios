import ComposableArchitecture
import FirebaseAuthClient
import ProfileClient
import SwiftUI
import Colors
import God
import GodClient

public struct FirstNameSettingReducer: Reducer {
  public init() {}

  public struct State: Equatable {
    var doubleCheckName = DoubleCheckNameReducer.State()
    var firstName = ""
    public init() {}
  }

  public enum Action: Equatable {
    case firstNameChanged(String)
    case nextButtonTapped
    case delegate(Delegate)
    case doubleCheckName(DoubleCheckNameReducer.Action)

    public enum Delegate: Equatable {
      case nextScreen
    }
  }

  @Dependency(\.profileClient) var profileClient
  @Dependency(\.firebaseAuth.currentUser) var currentUser

  public var body: some Reducer<State, Action> {
    Scope(state: \.doubleCheckName, action: /Action.doubleCheckName) {
      DoubleCheckNameReducer()
    }
    Reduce { state, action in
      switch action {
      case let .firstNameChanged(firstName):
        state.firstName = firstName
        return .none

      case .nextButtonTapped:
        guard let uid = currentUser()?.uid else {
          return .none
        }
        return .run { [firstName = state.firstName] send in
          try await profileClient.setUserProfile(
            uid: uid,
            field: .init(firstName: firstName)
          )
          await send(.delegate(.nextScreen))
        }

      case .delegate:
        return .none
      case .doubleCheckName:
        return .none
      }
    }
  }
}

public struct FirstNameSettingView: View {
  let store: StoreOf<FirstNameSettingReducer>

  public init(store: StoreOf<FirstNameSettingReducer>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      VStack {
        Spacer()
        Text("What's your first name?")
          .bold()
          .foregroundColor(.white)
        TextField(
          "First Name",
          text: viewStore.binding(
            get: \.firstName,
            send: FirstNameSettingReducer.Action.firstNameChanged
          )
        )
        .font(.title)
        .foregroundColor(.white)
        .multilineTextAlignment(.center)
        .textContentType(.givenName)
        Spacer()
        NextButton {
          viewStore.send(.nextButtonTapped)
        }
      }
      .padding(.horizontal, 24)
      .padding(.bottom, 16)
      .background(Color.godService)
      .navigationBarBackButtonHidden()
      .toolbar {
        DoubleCheckNameView(
          store: store.scope(
            state: \.doubleCheckName,
            action: FirstNameSettingReducer.Action.doubleCheckName
          )
        )
      }
    }
  }
}

struct FirstNameSettingViewPreviews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      FirstNameSettingView(
        store: .init(
          initialState: FirstNameSettingReducer.State(),
          reducer: { FirstNameSettingReducer() }
        )
      )
    }
  }
}
