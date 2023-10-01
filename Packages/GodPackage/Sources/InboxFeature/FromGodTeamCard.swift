import ButtonStyles
import Colors
import SwiftUI
import UserDefaultsClient
import ComposableArchitecture

public struct FromGodTeamCardLogic: Reducer {
  public struct State: Equatable {
    var isRead = false
  }
  
  public enum Action: Equatable {
    case onTask
    case cardButtonTapped
    case delegate(Delegate)
    
    public enum Delegate: Equatable {
      case showDetail
    }
  }
  
  @Dependency(\.userDefaults) var userDefaults
  
  public var body: some Reducer<State, Action> {
    Reduce<State, Action> { state, action in
      switch action {
      case .onTask:
        state.isRead = userDefaults.readInitialGodTeamNotification()
        return .none

      case .cardButtonTapped:
        return .run { send in
          await userDefaults.setReadInitialGodTeamNotification()
          await send(.delegate(.showDetail))
        }
      case .delegate:
        return .none
      }
    }
  }
}

public struct FromGodTeamCard: View {
  let store: StoreOf<FromGodTeamCardLogic>
  
  public init(store: StoreOf<FromGodTeamCardLogic>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      Button {
        viewStore.send(.cardButtonTapped)
      } label: {
        HStack(spacing: 0) {
          LabeledContent {
            Text(Date.now, style: .relative)
          } label: {
            Label {
              Text("From God Team", bundle: .module)
            } icon: {
              Image(ImageResource.godTeamIcon)
                .resizable()
                .scaledToFit()
                .frame(width: 40)
            }
          }
          .padding(.horizontal, 16)
        }
        .frame(height: 72)
        .foregroundStyle(viewStore.isRead ? Color.godTextSecondaryLight : Color.primary)
        .background(viewStore.isRead ? Color.godBackgroundWhite : Color.white)
        .cornerRadius(8)
        .compositingGroup()
        .shadow(color: Color.black.opacity(0.1), radius: 10)
      }
      .listRowSeparator(.hidden)
      .buttonStyle(HoldDownButtonStyle())
    }
  }
}
