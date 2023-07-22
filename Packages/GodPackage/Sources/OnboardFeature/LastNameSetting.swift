import ComposableArchitecture
import SwiftUI

public struct LastNameSettingReducer: ReducerProtocol {
  public init() {}
  
  public struct State: Equatable {
    @BindingState var lastName = ""
    public init() {}
  }
  
  public enum Action: Equatable, BindableAction {
    case binding(BindingAction<State>)
  }
  
  public var body: some ReducerProtocol<State, Action> {
    BindingReducer()
    Reduce { _, action in
      switch action {
      case .binding:
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
        TextField("Last Name", text: viewStore.binding(\.$lastName))
          .font(.title)
          .foregroundColor(.white)
          .multilineTextAlignment(.center)
        Spacer()
        Button {
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
      .background(Color(0xFFED6C43))
      .toolbar {
        Button {
          
        } label: {
          Image(systemName: "info.circle.fill")
            .foregroundColor(.white)
        }
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
          reducer: LastNameSettingReducer()
        )
      )
    }
  }
}
