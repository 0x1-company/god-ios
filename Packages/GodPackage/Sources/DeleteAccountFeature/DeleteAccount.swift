import AnalyticsClient
import ComposableArchitecture
import DeleteAccountReasonClient
import FirebaseAuthClient
import Styleguide
import SwiftUI

public struct DeleteAccountLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    @PresentationState var confirmationDialog: ConfirmationDialogState<Action.ConfirmationDialog>?
    @BindingState var otherReason = ""
    var selectedReasons: [String] = []
    let reasons = [
      String(localized: "Safety or privacy conerns", bundle: .module),
      String(localized: "I want to create a new account", bundle: .module),
      String(localized: "I don't use god anymore", bundle: .module),
      String(localized: "I don't know how to use it", bundle: .module),
    ]
    public init() {}
  }

  public enum Action: Equatable, BindableAction {
    case onTask
    case onAppear
    case closeButtonTapped
    case reasonButtonTapped(String)
    case deleteButtonTapped
    case notNowButtonTapped
    case binding(BindingAction<State>)
    case confirmationDialog(PresentationAction<ConfirmationDialog>)
    
    public enum ConfirmationDialog: Equatable {
      case confirm
    }
  }

  @Dependency(\.dismiss) var dismiss
  @Dependency(\.analytics) var analytics
  @Dependency(\.firebaseAuth) var firebaseAuth
  @Dependency(\.deleteAccountReasons) var deleteAccountReasons

  public var body: some Reducer<State, Action> {
    BindingReducer()
    Reduce<State, Action> { state, action in
      switch action {
      case .onTask:
        return .none

      case .onAppear:
        analytics.logScreen(screenName: "DeleteAccount", of: self)
        return .none

      case .closeButtonTapped:
        analytics.buttonClick(name: .close)
        return .run { _ in
          await dismiss()
        }
      case .notNowButtonTapped:
        analytics.buttonClick(name: .notNow)
        return .run { _ in
          await dismiss()
        }
      case let .reasonButtonTapped(reason):
        if state.selectedReasons.contains(reason) {
          state.selectedReasons = state.selectedReasons.filter { $0 != reason }
        } else {
          state.selectedReasons.append(reason)
        }
        return .none
        
      case .deleteButtonTapped:
        state.confirmationDialog = ConfirmationDialogState {
          TextState("Delete Account", bundle: .module)
        } actions: {
          ButtonState(role: .destructive, action: .confirm) {
            TextState("Confirm", bundle: .module)
          }
        } message: {
          TextState("Are you sure you want to delete your account?", bundle: .module)
        }
        return .none
        
      case .confirmationDialog(.presented(.confirm)):
        guard let currentUser = firebaseAuth.currentUser()
        else { return .none }
        let reasons = state.selectedReasons + [state.otherReason].filter { !$0.isEmpty }

        let param = DeleteAccountReasonClient.InsertParam(
          uid: currentUser.uid,
          reasons: reasons
        )

        return .run { _ in
          analytics.buttonClick(name: .delete, parameters: ["reasons": reasons])
          try await deleteAccountReasons.insert(param)
          try await currentUser.delete()
        }

      default:
        return .none
      }
    }
  }
}

public struct DeleteAccountView: View {
  let store: StoreOf<DeleteAccountLogic>

  public init(store: StoreOf<DeleteAccountLogic>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      ScrollView(showsIndicators: false) {
        VStack(spacing: 16) {
          VStack(spacing: 20) {
            Text("Are you sure you want to delete your account?", bundle: .module)
              .font(.system(.body, design: .rounded, weight: .bold))

            Text("All account information will be deleted, including friends, stars, and coin.", bundle: .module)
          }
          Text("This **cannot** be undone or recovered.", bundle: .module)

          VStack(spacing: 0) {
            ForEach(viewStore.reasons, id: \.self) { reason in
              Button {
                store.send(.reasonButtonTapped(reason))
              } label: {
                HStack(spacing: 0) {
                  Text(reason)
                    .foregroundStyle(Color.black)
                    .font(.system(.body, design: .rounded))
                    .frame(maxWidth: .infinity, alignment: .leading)

                  Rectangle()
                    .fill(
                      viewStore.selectedReasons.contains(reason)
                        ? Color.godService
                        : Color.white
                    )
                    .frame(width: 18, height: 18)
                    .clipShape(Circle())
                    .overlay(
                      RoundedRectangle(cornerRadius: 18 / 2)
                        .stroke(
                          viewStore.selectedReasons.contains(reason)
                            ? Color.godService
                            : Color.godTextSecondaryLight,
                          lineWidth: 2
                        )
                    )
                }
                .frame(height: 54)
                .padding(.horizontal, 16)
              }
              Divider()
            }

            TextField(
              String(localized: "Other Reason", bundle: .module),
              text: viewStore.$otherReason,
              axis: .vertical
            )
            .lineLimit(1 ... 10)
            .frame(minHeight: 54)
            .padding(.horizontal, 16)
            .multilineTextAlignment(.leading)
          }
          .frame(maxWidth: .infinity)
          .background(Color.white)
          .cornerRadius(16)
          .overlay(
            RoundedRectangle(cornerRadius: 16)
              .stroke(Color.godSeparator)
          )

          Button {
            store.send(.deleteButtonTapped)
          } label: {
            Text("Proceed with Deletion", bundle: .module)
              .frame(height: 56)
              .frame(maxWidth: .infinity)
              .background(Color.godService)
              .foregroundStyle(Color.white)
              .font(.system(.body, design: .rounded, weight: .bold))
              .clipShape(Capsule())
          }
          .buttonStyle(HoldDownButtonStyle())

          Button {
            store.send(.notNowButtonTapped)
          } label: {
            Text("Not Now", bundle: .module)
              .frame(height: 56)
              .frame(maxWidth: .infinity)
              .background(Color.godGray)
              .foregroundStyle(Color.white)
              .font(.system(.body, design: .rounded, weight: .bold))
              .clipShape(Capsule())
          }
          .buttonStyle(HoldDownButtonStyle())
        }
        .padding(.top, 48)
        .padding(.horizontal, 24)
        .multilineTextAlignment(.center)
      }
      .background(Color(uiColor: UIColor.systemGroupedBackground))
      .navigationTitle(Text("Delete Account", bundle: .module))
      .navigationBarTitleDisplayMode(.inline)
      .task { await store.send(.onTask).finish() }
      .onAppear { store.send(.onAppear) }
      .toolbar {
        ToolbarItem(placement: .topBarLeading) {
          Button {
            store.send(.closeButtonTapped)
          } label: {
            Text("Close", bundle: .module)
              .font(.system(.body, design: .rounded))
              .foregroundStyle(Color.black)
          }
        }
      }
      .confirmationDialog(
        store: store.scope(
          state: \.$confirmationDialog,
          action: DeleteAccountLogic.Action.confirmationDialog
        )
      )
    }
  }
}

#Preview {
  NavigationStack {
    DeleteAccountView(
      store: .init(
        initialState: DeleteAccountLogic.State(),
        reducer: { DeleteAccountLogic() }
      )
    )
  }
  .environment(\.locale, Locale(identifier: "ja-JP"))
}
