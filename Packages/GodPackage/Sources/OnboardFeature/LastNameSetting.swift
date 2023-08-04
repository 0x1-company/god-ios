import ComposableArchitecture
import SwiftUI

public struct LastNameSettingReducer: Reducer {
  public init() {}

  public struct State: Equatable {
    var doubleCheckName = DoubleCheckNameReducer.State()
    @BindingState var lastName = ""
    public init() {}
  }

  public enum Action: Equatable, BindableAction {
    case doubleCheckName(DoubleCheckNameReducer.Action)
    case binding(BindingAction<State>)
    case nextButtonTapped
    case delegate(Delegate)
    
    public enum Delegate: Equatable {
      case next
    }
  }

  public var body: some Reducer<State, Action> {
    BindingReducer()
    Scope(state: \.doubleCheckName, action: /Action.doubleCheckName) {
      DoubleCheckNameReducer()
    }
    Reduce { _, action in
      switch action {
      case .doubleCheckName:
        return .none

      case .binding:
        return .none
        
      case .nextButtonTapped:
        return .run { send in
          await send(.delegate(.next))
        }
      case .delegate:
        return .none
      }
    }
  }
}

public struct LastNameSettingView: View {
  let store: StoreOf<LastNameSettingReducer>

  public init(store: StoreOf<LastNameSettingReducer>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      VStack {
        Spacer()
        Text("What's your last name?")
          .bold()
          .foregroundColor(.white)
        TextField("Last Name", text: viewStore.$lastName)
          .font(.title)
          .foregroundColor(.white)
          .multilineTextAlignment(.center)
          .textContentType(.familyName)
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
      .toolbar {
        DoubleCheckNameView(
          store: store.scope(
            state: \.doubleCheckName,
            action: LastNameSettingReducer.Action.doubleCheckName
          )
        )
      }
    }
  }
}

struct LastNameSettingViewPreviews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      LastNameSettingView(
        store: .init(
          initialState: LastNameSettingReducer.State(),
          reducer: { LastNameSettingReducer() }
        )
      )
    }
  }
}
