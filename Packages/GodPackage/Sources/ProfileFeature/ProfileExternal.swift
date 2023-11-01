import AnalyticsClient
import AsyncValue
import ComposableArchitecture
import God
import GodClient
import SwiftUI

public struct ProfileExternalLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    var userId: String
    var user = AsyncValue<God.UserQuery.Data.User>.none

    @PresentationState var alert: AlertState<Action.Alert>?
    @PresentationState var confirmationDialog: ConfirmationDialogState<Action.ConfirmationDialog>?

    public init(userId: String) {
      self.userId = userId
    }
  }

  public enum Action: Equatable {
    case onTask
    case onAppear
    case closeButtonTapped
    case blockButtonTapped
    case reportButtonTapped
    case userResponse(TaskResult<God.UserQuery.Data>)
    case alert(PresentationAction<Alert>)
    case confirmationDialog(PresentationAction<ConfirmationDialog>)

    public enum Alert: Equatable {
      case block
    }

    public enum ConfirmationDialog: Equatable {
      case inappropriatePhoto
      case pretendingToBeSomeoneElse
      case mayBeUnder13YearsOld
      case doesNotGoYoMySchool
      case bullying
      case other
    }
  }

  @Dependency(\.dismiss) var dismiss
  @Dependency(\.godClient) var godClient
  @Dependency(\.analytics) var analytics

  enum Cancel { case user }

  public var body: some Reducer<State, Action> {
    Reduce<State, Action> { state, action in
      switch action {
      case .onTask:
        state.user = .loading
        let userWhere = God.UserWhere(id: .init(stringLiteral: state.userId))
        return .run { send in
          for try await data in godClient.user(userWhere) {
            await send(.userResponse(.success(data)))
          }
        } catch: { error, send in
          await send(.userResponse(.failure(error)))
        }
        .cancellable(id: Cancel.user, cancelInFlight: true)

      case .onAppear:
        analytics.logScreen(screenName: "ProfileExternal", of: self, parameters: [
          "userId": state.userId,
        ])
        return .none

      case .closeButtonTapped:
        return .run { _ in
          await dismiss()
        }

      case let .userResponse(.success(data)):
        state.user = .success(data.user)
        return .none

      case .userResponse(.failure):
        state.user = .none
        return .run { _ in
          await dismiss()
        }

      case .blockButtonTapped:
        state.confirmationDialog = nil
        state.alert = .block
        return .none

      case .reportButtonTapped:
        state.alert = nil
        state.confirmationDialog = .report
        return .none

      default:
        return .none
      }
    }
  }
}

public struct ProfileExternalView: View {
  let store: StoreOf<ProfileExternalLogic>

  public init(store: StoreOf<ProfileExternalLogic>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      ScrollView {
        LazyVStack(alignment: .leading, spacing: 0) {
          if case let .success(user) = viewStore.user {
            ProfileSection(
              imageURL: user.imageURL,
              friendsCount: user.friendsCount ?? 0,
              votedCount: user.votedCount,
              username: user.username ?? "",
              firstName: user.firstName,
              lastName: user.lastName,
              displayName: user.displayName.ja,
              schoolShortName: user.school?.shortName,
              grade: user.grade
            )
          } else if case .loading = viewStore.user {
            ProgressView()
              .progressViewStyle(.circular)
          }
        }
      }
      .navigationTitle(Text("Profile", bundle: .module))
      .navigationBarTitleDisplayMode(.inline)
      .task { await store.send(.onTask).finish() }
      .onAppear { store.send(.onAppear) }
      .alert(store: store.scope(state: \.$alert, action: { .alert($0) }))
      .confirmationDialog(store: store.scope(state: \.$confirmationDialog, action: { .confirmationDialog($0) }))
      .toolbar {
        ToolbarItem(placement: .topBarLeading) {
          Menu {
            Button {
              store.send(.blockButtonTapped)
            } label: {
              Text("Block User", bundle: .module)
            }
            Button {
              store.send(.reportButtonTapped)
            } label: {
              Text("Report User", bundle: .module)
            }
          } label: {
            Image(systemName: "ellipsis")
              .foregroundStyle(Color.secondary)
          }
        }
        ToolbarItem(placement: .topBarTrailing) {
          Button {
            store.send(.closeButtonTapped)
          } label: {
            Image(systemName: "xmark")
              .foregroundStyle(Color.secondary)
          }
        }
      }
    }
  }
}

#Preview {
  ProfileExternalView(
    store: .init(
      initialState: ProfileExternalLogic.State(userId: ""),
      reducer: { ProfileExternalLogic() }
    )
  )
}

extension ConfirmationDialogState where Action == ProfileExternalLogic.Action.ConfirmationDialog {
  static let report = Self {
    TextState("Report User", bundle: .module)
  } actions: {
    ButtonState(action: .inappropriatePhoto) {
      TextState("Inappropriate photo", bundle: .module)
    }
    ButtonState(action: .pretendingToBeSomeoneElse) {
      TextState("Pretending to be someone else", bundle: .module)
    }
    ButtonState(action: .mayBeUnder13YearsOld) {
      TextState("May be under 13 years old", bundle: .module)
    }
    ButtonState(action: .doesNotGoYoMySchool) {
      TextState("Does not go to my school", bundle: .module)
    }
    ButtonState(action: .bullying) {
      TextState("Bullying", bundle: .module)
    }
    ButtonState(action: .other) {
      TextState("Other", bundle: .module)
    }
  } message: {
    TextState("Please select a reason", bundle: .module)
  }
}

extension AlertState where Action == ProfileExternalLogic.Action.Alert {
  static let block = Self {
    TextState("Are you sure?", bundle: .module)
  } actions: {
    ButtonState(role: .destructive, action: .block) {
      TextState("Block", bundle: .module)
    }
    ButtonState(role: .cancel) {
      TextState("Cancel", bundle: .module)
    }
  } message: {
    TextState("You won't see this user again in the app.", bundle: .module)
  }
}
