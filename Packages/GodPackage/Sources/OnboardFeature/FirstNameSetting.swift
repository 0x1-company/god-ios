import ComposableArchitecture
import SwiftUI
import ProfileClient
import FirebaseAuthClient

public struct FirstNameSettingReducer: Reducer {
  public init() {}

  public struct State: Equatable {
    var doubleCheckName = DoubleCheckNameReducer.State()
    @BindingState var firstName = ""
    public init() {}
  }

  public enum Action: Equatable, BindableAction {
    case doubleCheckName(DoubleCheckNameReducer.Action)
    case binding(BindingAction<State>)
    case nextButtonTapped
    case delegate(Delegate)

    public enum Delegate: Equatable {
      case nextLastNameSetting
    }
  }
  
  enum CancelId { case effect }
  
  @Dependency(\.profileClient) var profileClient
  @Dependency(\.firebaseAuth.currentUser) var currentUser

  public var body: some Reducer<State, Action> {
    BindingReducer()
    Scope(state: \.doubleCheckName, action: /Action.doubleCheckName) {
      DoubleCheckNameReducer()
    }
    Reduce { state, action in
      switch action {
      case .doubleCheckName:
        return .none

      case .binding:
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
          await send(.delegate(.nextLastNameSetting))
        }
      case .delegate:
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
        TextField("First Name", text: viewStore.$firstName)
          .font(.title)
          .foregroundColor(.white)
          .multilineTextAlignment(.center)
          .textContentType(.givenName)
        Spacer()
        Button {
          viewStore.send(.nextButtonTapped)
        } label: {
          Text("Next")
            .bold()
            .frame(height: 54)
            .frame(maxWidth: .infinity)
            .foregroundColor(Color.black)
            .background(Color.white)
            .clipShape(Capsule())
        }
      }
      .padding(.horizontal, 24)
      .padding(.bottom, 16)
      .background(Color(0xFFED_6C43))
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
