import AnalyticsClient
import Apollo
import ComposableArchitecture
import Contacts
import God
import GodClient
import StringHelpers
import Styleguide
import SwiftUI
import UserDefaultsClient

public struct LastNameSettingLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    @BindingState var lastName = ""
    var isDisabled = true
    var isImport = false
    public init() {}
  }

  public enum Action: Equatable, BindableAction {
    case onTask
    case onAppear
    case nextButtonTapped
    case binding(BindingAction<State>)
    case updateProfileResponse(TaskResult<God.UpdateUserProfileMutation.Data>)
    case delegate(Delegate)

    public enum Delegate: Equatable {
      case nextScreen
    }
  }

  @Dependency(\.analytics) var analytics
  @Dependency(\.godClient) var godClient
  @Dependency(\.contacts) var contactsClient
  @Dependency(\.userDefaults) var userDefaults

  public var body: some Reducer<State, Action> {
    BindingReducer()
    Reduce<State, Action> { state, action in
      switch action {
      case .onTask:
        guard
          case .authorized = contactsClient.authorizationStatus(.contacts),
          let number = userDefaults.phoneNumber(),
          let contact = try? contactsClient.findByPhoneNumber(number: number).first,
          let transformedLastName = try? transformToHiragana(for: contact.phoneticFamilyName)
        else { return .none }
        state.lastName = transformedLastName
        state.isImport = true
        return .none

      case .onAppear:
        analytics.logScreen(screenName: "LastNameSetting", of: self)
        return .none

      case .nextButtonTapped:
        let input = God.UpdateUserProfileInput(
          lastName: .init(stringLiteral: state.lastName)
        )
        return .run { send in
          async let next: Void = send(.delegate(.nextScreen))
          async let update: Void = send(.updateProfileResponse(TaskResult {
            try await godClient.updateUserProfile(input)
          }))
          _ = await (next, update)
        }
      case .binding:
        state.isDisabled = state.lastName.isEmpty || !validateHiragana(for: state.lastName)
        return .none
      default:
        return .none
      }
    }
  }
}

public struct LastNameSettingView: View {
  let store: StoreOf<LastNameSettingLogic>
  @FocusState var focus: Bool

  public init(store: StoreOf<LastNameSettingLogic>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      VStack(spacing: 8) {
        Spacer()
        Text("What's your last name?", bundle: .module)
          .font(.system(.title3, design: .rounded, weight: .bold))

        Text("Only hiragana can be set", bundle: .module)

        TextField(text: viewStore.$lastName) {
          Text("Last Name", bundle: .module)
        }
        .multilineTextAlignment(.center)
        .font(.system(.title, design: .rounded))
        .focused($focus)

        if viewStore.isImport {
          Text("Imported from Contacts", bundle: .module)
            .font(.system(.body, design: .rounded, weight: .bold))
        }
        Spacer()
        NextButton(isDisabled: viewStore.isDisabled) {
          store.send(.nextButtonTapped)
        }
      }
      .padding(.horizontal, 24)
      .padding(.bottom, 16)
      .foregroundStyle(Color.white)
      .background(Color.godService)
      .navigationBarBackButtonHidden()
      .task { await store.send(.onTask).finish() }
      .onAppear {
        focus = true
        store.send(.onAppear)
      }
    }
  }
}

struct LastNameSettingViewPreviews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      LastNameSettingView(
        store: .init(
          initialState: LastNameSettingLogic.State(),
          reducer: { LastNameSettingLogic() }
        )
      )
    }
  }
}
