import ButtonStyles
import Colors
import ComposableArchitecture
import SwiftUI
import SearchField

public struct PickFriendToAddYourNameTheirPollLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    @BindingState var searchQuery = ""
    public init() {}
  }

  public enum Action: Equatable, BindableAction {
    case onTask
    case nextButtonTapped
    case closeButtonTapped
    case binding(BindingAction<State>)
  }
  
  @Dependency(\.dismiss) var dismiss

  public var body: some Reducer<State, Action> {
    BindingReducer()
    Reduce<State, Action> { _, action in
      switch action {
      case .onTask:
        return .none
        
      case .nextButtonTapped:
        return .none
        
      case .closeButtonTapped:
        return .run { _ in
          await dismiss()
        }
      case .binding:
        return .none
      }
    }
  }
}

public struct PickFriendToAddYourNameTheirPollView: View {
  let store: StoreOf<PickFriendToAddYourNameTheirPollLogic>

  public init(store: StoreOf<PickFriendToAddYourNameTheirPollLogic>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      VStack(spacing: 0) {
        Text("Pick a friend to add\nyour name to their polls", bundle: .module)
          .bold()
          .font(.title2)
          .foregroundStyle(Color.godWhite)
          .multilineTextAlignment(.center)
          .frame(maxWidth: .infinity)
          .padding(.bottom, 46)
          .background(Color.godService)
        
        SearchField(text: viewStore.$searchQuery)
        
        Divider()
        
        List {
          
        }
      }
      .task { await viewStore.send(.onTask).finish() }
      .toolbar {
        ToolbarItem(placement: .topBarLeading) {
          Button {
            viewStore.send(.closeButtonTapped)
          } label: {
            Image(systemName: "xmark")
              .foregroundStyle(.white)
          }
          .buttonStyle(HoldDownButtonStyle())
        }
        
        ToolbarItem(placement: .topBarTrailing) {
          Button {
            viewStore.send(.nextButtonTapped)
          } label: {
            Text("Next", bundle: .module)
              .bold()
              .foregroundStyle(.white)
          }
          .buttonStyle(HoldDownButtonStyle())
        }
      }
    }
  }
}

#Preview {
  NavigationStack {
    PickFriendToAddYourNameTheirPollView(
      store: .init(
        initialState: PickFriendToAddYourNameTheirPollLogic.State(),
        reducer: { PickFriendToAddYourNameTheirPollLogic() }
      )
    )
  }
}
