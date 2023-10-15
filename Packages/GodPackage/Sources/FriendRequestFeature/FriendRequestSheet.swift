import BackgroundClearSheet
import ComposableArchitecture
import God
import GodClient
import Styleguide
import SwiftUI
import ProfileImage

public struct FriendRequestSheetLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    let user: God.FriendRequestSheetFragment

    public init(user: God.FriendRequestSheetFragment) {
      self.user = user
    }
  }

  public enum Action: Equatable {
    case onTask
    case dismissButtonTapped
  }
  
  @Dependency(\.dismiss) var dismiss
  @Dependency(\.godClient) var godClient

  public var body: some Reducer<State, Action> {
    Reduce<State, Action> { _, action in
      switch action {
      case .onTask:
        return .none
        
      case .dismissButtonTapped:
        return .run { _ in
          await self.dismiss()
        }
      }
    }
  }
}

public struct FriendRequestSheetView: View {
  let store: StoreOf<FriendRequestSheetLogic>

  public init(store: StoreOf<FriendRequestSheetLogic>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      VStack {
        Spacer()
          .onTapGesture {
            store.send(.dismissButtonTapped)
          }
        
        VStack(spacing: 18) {
          HStack {
            
            Spacer()
            
            Button {
              store.send(.dismissButtonTapped)
            } label: {
              Image(systemName: "chevron.down")
                .frame(width: 52, height: 52)
                .foregroundStyle(Color.secondary)
            }
          }
          Spacer()

          VStack(spacing: 4) {
            Text(viewStore.user.displayName.ja)
              .font(.system(.body, design: .rounded, weight: .bold))
            
            if let username = viewStore.user.username {
              Text("@\(username)", bundle: .module)
                .font(.system(.footnote, design: .rounded))
                .foregroundStyle(Color.secondary)
            }
          }
          
          HStack(spacing: 0) {
            Image(ImageResource.star)
              .resizable()
              .frame(width: 24, height: 24)
            
            Text(viewStore.user.votedCount.description)
          }
          .foregroundStyle(Color.secondary)
          
          Button {
            
          } label: {
            Text("ADD", bundle: .module)
              .frame(width: 96, height: 34)
              .foregroundStyle(Color.white)
              .background(Color.godService)
              .clipShape(Capsule())
              .font(.system(.body, design: .rounded, weight: .bold))
          }
        }
        .frame(height: 220)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .overlay(alignment: .top) {
          ProfileImage(
            urlString: viewStore.user.imageURL,
            name: viewStore.user.firstName,
            size: 150
          )
          .overlay {
            RoundedRectangle(cornerRadius: 75)
              .stroke(Color.white, lineWidth: 4)
          }
          .offset(y: -75)
        }
      }
      .buttonStyle(HoldDownButtonStyle())
      .task { await viewStore.send(.onTask).finish() }
    }
  }
}

#Preview {
  Color.red
    .ignoresSafeArea()
    .sheet(isPresented: .constant(true)) {
      FriendRequestSheetView(
        store: .init(
          initialState: FriendRequestSheetLogic.State(
            user: God.FriendRequestSheetFragment(
              _dataDict: DataDict(
                data: [
                  "id": "test",
                  "firstName": "Tomoki",
                  "username": "tomokisun",
                  "votedCount": 10,
                  "grade": "Grade 9",
                  "imageURL": "https://storage.googleapis.com/god-staging.appspot.com/users/profile_images/1571f30f-6320-4e61-8e98-225b57b14c9a",
                  "displayName": DataDict(
                    data: [
                      "ja": "Tomoki Tsukiyama"
                    ],
                    fulfilledFragments: []
                  ),
                  "school": DataDict(
                    data: [
                      "id": "KHS",
                      "shortName": "KHS"
                    ],
                    fulfilledFragments: []
                  )
                ],
                fulfilledFragments: []
              )
            )
          ),
          reducer: { FriendRequestSheetLogic() }
        )
      )
      .presentationBackground(Color.clear)
    }
}
