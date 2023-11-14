import AnalyticsClient
import ComposableArchitecture
import FirebaseAuthClient
import PhoneNumberDependencies
import PhoneNumberKit
import Styleguide
import SwiftUI
import UserDefaultsClient

@Reducer
public struct PhoneNumberLogic {
  public struct State: Equatable {
    @BindingState var phoneNumber = ""
    var isDisabled = true
    var isActivityIndicatorVisible = false
    @PresentationState var alert: AlertState<Action.Alert>?
    @PresentationState var help: PhoneNumberHelpLogic.State?
    public init() {}
  }

  public enum Action: BindableAction {
    case onAppear
    case infoButtonTapped
    case nextButtonTapped
    case binding(BindingAction<State>)
    case verifyResponse(TaskResult<String?>)
    case alert(PresentationAction<Alert>)
    case help(PresentationAction<PhoneNumberHelpLogic.Action>)
    case delegate(Delegate)

    public enum Delegate: Equatable {
      case nextScreen
    }

    public enum Alert: Equatable {
      case confirmOkay
    }
  }

  @Dependency(\.analytics) var analytics
  @Dependency(\.userDefaults) var userDefaults
  @Dependency(\.phoneNumberParse) var phoneNumberParse
  @Dependency(\.phoneNumberFormat) var phoneNumberFormat
  @Dependency(\.isValidPhoneNumber) var isValidPhoneNumber
  @Dependency(\.firebaseAuth.verifyPhoneNumber) var verifyPhoneNumber

  public var body: some Reducer<State, Action> {
    BindingReducer()
    Reduce<State, Action> { state, action in
      switch action {
      case .onAppear:
        analytics.logScreen(screenName: "PhoneNumber", of: self)
        return .none
      case .infoButtonTapped:
        state.help = .init()
        return .none
      case .nextButtonTapped:
        guard
          isValidPhoneNumber(state.phoneNumber),
          let parse = try? phoneNumberParse(state.phoneNumber, withRegion: "JP", ignoreType: true)
        else { return .none }
        state.isActivityIndicatorVisible = true
        let format = phoneNumberFormat(parse)
        return .run { [state] send in
          await userDefaults.setPhoneNumber(state.phoneNumber)
          await send(
            .verifyResponse(
              TaskResult {
                try await verifyPhoneNumber(format)
              }
            )
          )
        }
      case .binding:
        state.isDisabled = !isValidPhoneNumber(state.phoneNumber)
        return .none
      case let .verifyResponse(.success(id)):
        state.isActivityIndicatorVisible = false
        return .run { send in
          await userDefaults.setVerificationId(id ?? "")
          await send(.delegate(.nextScreen), animation: .default)
        }
      case let .verifyResponse(.failure(error)):
        state.isActivityIndicatorVisible = false
        state.alert = AlertState {
          TextState("Error")
        } actions: {
          ButtonState(action: .send(.confirmOkay, animation: .default)) {
            TextState("OK")
          }
        } message: {
          TextState(error.localizedDescription)
        }
        return .none

      case .alert(.presented(.confirmOkay)):
        state.alert = nil
        return .none

      case .alert:
        return .none

      case .help:
        return .none

      case .delegate:
        return .none
      }
    }
    .ifLet(\.$help, action: \.help) {
      PhoneNumberHelpLogic()
    }
  }
}

public struct PhoneNumberView: View {
  let store: StoreOf<PhoneNumberLogic>
  @FocusState var focus: Bool

  public init(store: StoreOf<PhoneNumberLogic>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      ZStack {
        Color.godService
          .ignoresSafeArea()

        VStack(spacing: 12) {
          Spacer()
          Text("Enter your phone Number", bundle: .module)
            .font(.system(.title3, design: .rounded, weight: .bold))

          TextField(text: viewStore.$phoneNumber) {
            Text("080 8478 4955", bundle: .module)
          }
          .font(.system(.title, design: .rounded))
          .textContentType(.telephoneNumber)
          .keyboardType(.phonePad)
          .focused($focus)

          Spacer()

          NextButton(
            isLoading: viewStore.isActivityIndicatorVisible,
            isDisabled: viewStore.isDisabled
          ) {
            store.send(.nextButtonTapped)
          }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .foregroundStyle(Color.godWhite)
        .multilineTextAlignment(.center)
      }
      .navigationBarBackButtonHidden()
      .alert(store: store.scope(state: \.$alert, action: PhoneNumberLogic.Action.alert))
      .sheet(
        store: store.scope(state: \.$help, action: PhoneNumberLogic.Action.help),
        content: { store in
          PhoneNumberHelpView(store: store)
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
      )
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          Button {
            store.send(.infoButtonTapped)
          } label: {
            Image(systemName: "info.circle.fill")
              .foregroundStyle(Color.white)
          }
        }
      }
      .onAppear {
        focus = true
        store.send(.onAppear)
      }
    }
  }
}

#Preview {
  NavigationStack {
    PhoneNumberView(
      store: .init(
        initialState: PhoneNumberLogic.State(),
        reducer: { PhoneNumberLogic() }
      )
    )
  }
}
