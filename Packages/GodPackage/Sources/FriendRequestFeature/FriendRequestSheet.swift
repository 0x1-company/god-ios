import AnalyticsClient
import BackgroundClearSheet
import ComposableArchitecture
import God
import GodClient
import ProfileImage
import Styleguide
import SwiftUI

public struct FriendRequestSheetLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    let friend: God.FriendRequestSheetFragment

    public init(friend: God.FriendRequestSheetFragment) {
      self.friend = friend
    }
  }

  public enum Action: Equatable {
    case onTask
    case dismissButtonTapped
    case approveButtonTapped
    case approveResponse(TaskResult<God.ApproveFriendRequestMutation.Data>)
  }

  @Dependency(\.dismiss) var dismiss
  @Dependency(\.godClient) var godClient
  @Dependency(\.analytics) var analytics

  public var body: some Reducer<State, Action> {
    Reduce<State, Action> { state, action in
      switch action {
      case .onTask:
        analytics.logScreen(screenName: "FriendRequestSheet", of: self)
        return .none

      case .dismissButtonTapped:
        return .run { _ in
          await dismiss()
        }
      case .approveButtonTapped:
        let input = God.ApproveFriendRequestInput(id: state.friend.id)
        return .run { send in
          await withTaskGroup(of: Void.self) { group in
            group.addTask {
              await dismiss()
            }
            group.addTask {
              await send(.approveResponse(TaskResult {
                try await godClient.approveFriendRequest(input)
              }))
            }
          }
        }
      default:
        return .none
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
        Color.clear
          .contentShape(Rectangle())
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
            Text(viewStore.friend.user.displayName.ja)
              .font(.system(.body, design: .rounded, weight: .bold))

            if let username = viewStore.friend.user.username {
              Text("@\(username)", bundle: .module)
                .font(.system(.footnote, design: .rounded))
                .foregroundStyle(Color.secondary)
            }
          }

          HStack(spacing: 12) {
            HStack(spacing: 0) {
              Image(ImageResource.star)
                .resizable()
                .frame(width: 24, height: 24)

              Text(viewStore.friend.user.votedCount.description)
            }

            if let shortName = viewStore.friend.user.school?.shortName {
              HStack(spacing: 4) {
                Image(systemName: "house.fill")
                  .resizable()
                  .frame(width: 16, height: 16)
                Text(verbatim: shortName)
              }
            }
            if let grade = viewStore.friend.user.grade {
              HStack(spacing: 4) {
                Image(systemName: "graduationcap.fill")
                  .resizable()
                  .frame(width: 16, height: 16)
                Text(verbatim: grade)
              }
            }
          }
          .tint(Color.godTextSecondaryLight)
          .foregroundStyle(Color.godTextSecondaryLight)

          Text("Friend request received!", bundle: .module)
            .font(.system(.body, design: .rounded, weight: .bold))

          Button {
            store.send(.approveButtonTapped)
          } label: {
            Text("ACCEPT", bundle: .module)
              .frame(height: 34)
              .padding(.horizontal, 24)
              .foregroundStyle(Color.white)
              .background(Color.godService)
              .clipShape(Capsule())
              .font(.system(.body, design: .rounded, weight: .bold))
          }
        }
        .frame(height: 260)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .overlay(alignment: .top) {
          ProfileImage(
            urlString: viewStore.friend.user.imageURL,
            name: viewStore.friend.user.firstName,
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
      .task { await store.send(.onTask).finish() }
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
            friend: God.FriendRequestSheetFragment(
              _dataDict: DataDict(
                data: [
                  "id": "hoge",
                  "user": DataDict(
                    data: [
                      "id": "test",
                      "firstName": "Tomoki",
                      "username": "tomokisun",
                      "votedCount": 10,
                      "grade": "Grade 9",
                      "imageURL": "https://storage.googleapis.com/god-staging.appspot.com/users/profile_images/1571f30f-6320-4e61-8e98-225b57b14c9a",
                      "displayName": DataDict(
                        data: [
                          "ja": "Tomoki Tsukiyama",
                        ],
                        fulfilledFragments: []
                      ),
                      "school": DataDict(
                        data: [
                          "id": "KHS",
                          "shortName": "KHS",
                        ],
                        fulfilledFragments: []
                      ),
                    ],
                    fulfilledFragments: []
                  ),
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
