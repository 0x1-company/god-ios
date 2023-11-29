import ComposableArchitecture
import God
import GodClient
import SwiftUI

@Reducer
public struct ReceivedActivityLogic {
  public init() {}

  public struct State: Equatable {
    let currentUser: God.CurrentUserQuery.Data.CurrentUser
    public init(currentUser: God.CurrentUserQuery.Data.CurrentUser) {
      self.currentUser = currentUser
    }
  }

  public enum Action {}

  public var body: some Reducer<State, Action> {
    EmptyReducer()
  }
}

public struct ReceivedActivityView: View {
  let store: StoreOf<ReceivedActivityLogic>

  public init(store: StoreOf<ReceivedActivityLogic>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      Text("You've already been praised 7 times.", bundle: .module)
        .foregroundStyle(Color.white)
        .font(.system(.title3, design: .rounded, weight: .bold))

      ReceivedActivityList(
        profileImageUrl: viewStore.currentUser.imageURL,
        name: viewStore.currentUser.firstName,
        displayName: viewStore.currentUser.displayName.ja,
        grade: viewStore.currentUser.grade,
        gender: viewStore.currentUser.gender
      )
      .padding(.horizontal, 24)
    }
  }
}
