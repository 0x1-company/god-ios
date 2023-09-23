import Colors
import ComposableArchitecture
import God
import GodClient
import SwiftUI
import NameImage

public struct AddFriendsLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    let schoolId: String?
    var users: [God.UsersBySchoolQuery.Data.UsersBySchoolId.Edge.Node] = []

    public init(schoolId: String?) {
      self.schoolId = schoolId
    }
  }

  public enum Action: Equatable {
    case onTask
    case nextButtonTapped
    case usersResponse(TaskResult<God.UsersBySchoolQuery.Data>)
    case delegate(Delegate)

    public enum Delegate: Equatable {
      case nextScreen
    }
  }
  
  @Dependency(\.godClient) var godClient

  public var body: some Reducer<State, Action> {
    Reduce<State, Action> { state, action in
      switch action {
      case .onTask:
        guard let schoolId = state.schoolId else { return .none }
        return .run { send in
          for try await data in godClient.usersBySchool(schoolId) {
            await send(.usersResponse(.success(data)))
          }
        } catch: { error, send in
          await send(.usersResponse(.failure(error)))
        }

      case .nextButtonTapped:
        return .run { send in
          await send(.delegate(.nextScreen))
        }
        
      case let .usersResponse(.success(data)):
        state.users = data.usersBySchoolId.edges.map(\.node)
        return .none
        
      case .usersResponse(.failure):
        return .none
        
      case .delegate:
        return .none
      }
    }
  }
}

public struct AddFriendsView: View {
  let store: StoreOf<AddFriendsLogic>

  public init(store: StoreOf<AddFriendsLogic>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      ScrollView {
        LazyVStack(spacing: 0) {
          Text("PEOPLE YOU MAY KNOW", bundle: .module)
            .bold()
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 34)
            .padding(.horizontal, 16)
            .foregroundColor(.secondary)
            .background(Color(uiColor: .quaternarySystemFill))

          Divider()
          
          ForEach(viewStore.users, id: \.self) { user in
            HStack(alignment: .center, spacing: 16) {
              AsyncImage(url: URL(string: user.imageURL)) { image in
                image
                  .resizable()
                  .scaledToFill()
                  .frame(width: 40, height: 40)
                  .clipShape(Circle())
              } placeholder: {
                NameImage(
                  familyName: user.lastName,
                  givenName: user.firstName,
                  size: 40
                )
              }

              VStack(alignment: .leading) {
                Text(user.displayName.ja)
              }

              Spacer()

              Color.white
                .frame(width: 26, height: 26)
                .overlay(
                  RoundedRectangle(cornerRadius: 26 / 2)
                    .stroke(Color.godTextSecondaryLight, lineWidth: 2)
                )
            }
            .padding(.horizontal, 16)
            .frame(height: 72)
            .background(Color.white)
            
            Divider()
          }
        }
      }
      .navigationTitle(Text("Add Friends", bundle: .module))
      .navigationBarTitleDisplayMode(.inline)
      .toolbarBackground(Color.godService, for: .navigationBar)
      .toolbarBackground(.visible, for: .navigationBar)
      .toolbarColorScheme(.dark, for: .navigationBar)
      .task { await viewStore.send(.onTask).finish() }
      .toolbar {
        Button("Next") {
          viewStore.send(.nextButtonTapped)
        }
        .bold()
        .foregroundColor(Color.white)
      }
    }
  }
}

//#Preview {
//  NavigationStack {
//    AddFriendsView(
//      store: .init(
//        initialState: AddFriendsLogic.State(
//          schoolId: "1"
//        ),
//        reducer: { AddFriendsLogic() }
//      )
//    )
//    AddFriendsView(
//      store: Store(initialState: AddFriendsLogic.State(schoolId: "")) {
//        AddFriendsLogic()
//      } withDependencies: {
//        $0.godClient.usersBySchool = { value in
//          AsyncThrowingStream { continuation in
//            continuation.yield(
//              God.UsersBySchoolQuery.Data(
//                _dataDict: DataDict(
//                  data: [:],
//                  fulfilledFragments: []
//                )
//              )
//            )
//          }
//        }
//      }
//    )
//  }
//}
