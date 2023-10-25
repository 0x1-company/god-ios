import AnalyticsClient
import Apollo
import ComposableArchitecture
import Contacts
import ContactsClient
import God
import GodClient
import StringHelpers
import Styleguide
import SwiftUI
import UserDefaultsClient

public struct FirstNameSettingLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    @BindingState var firstName = ""
    var isDisabled = true
    var isImport = false
    public init() {}
  }

  public enum Action: Equatable, BindableAction {
    case onTask
    case onAppear
    case nextButtonTapped
    case updateProfileResponse(TaskResult<God.UpdateUserProfileMutation.Data>)
    case binding(BindingAction<State>)
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
          let transformedFirstName = try? transformToHiragana(for: contact.phoneticGivenName)
        else { return .none }
        state.firstName = transformedFirstName
        state.isImport = true
        return .none

      case .onAppear:
        analytics.logScreen(screenName: "FirstNameSetting", of: self)
        return .none

      case .nextButtonTapped:
        let input = God.UpdateUserProfileInput(
          firstName: .init(stringLiteral: state.firstName)
        )
        return .run { send in
          async let next: Void = send(.delegate(.nextScreen))
          async let update: Void = send(.updateProfileResponse(TaskResult {
            try await godClient.updateUserProfile(input)
          }))
          _ = await (next, update)
        }
      case .binding:
        state.isDisabled = state.firstName.isEmpty || !validateHiragana(for: state.firstName)
        return .none

      default:
        return .none
      }
    }
  }
}

public struct FirstNameSettingView: View {
  let store: StoreOf<FirstNameSettingLogic>
  @FocusState var focus: Bool

  public init(store: StoreOf<FirstNameSettingLogic>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      VStack(spacing: 8) {
        Spacer()
        Text("What's your first name?", bundle: .module)
          .font(.system(.title3, design: .rounded, weight: .bold))

        Text("Only hiragana can be set", bundle: .module)

        TextField(text: viewStore.$firstName) {
          Text("First Name", bundle: .module)
        }
        .foregroundStyle(.white)
        .multilineTextAlignment(.center)
        .font(.system(.title, design: .rounded))
        .focused($focus)

        if viewStore.isImport {
          Text("Imported from Contacts", bundle: .module)
            .font(.system(.body, design: .rounded, weight: .bold))
        }
        Spacer()
        NextButton(isDisabled: viewStore.isDisabled) {
          viewStore.send(.nextButtonTapped)
        }
      }
      .padding(.horizontal, 24)
      .padding(.bottom, 16)
      .foregroundStyle(Color.white)
      .background(Color.godService)
      .task { await viewStore.send(.onTask).finish() }
      .onAppear {
        focus = true
        store.send(.onAppear)
      }
    }
  }
}

struct FirstNameSettingViewPreviews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      FirstNameSettingView(
        store: .init(
          initialState: FirstNameSettingLogic.State(),
          reducer: { FirstNameSettingLogic() }
        )
      )
    }
  }
}
