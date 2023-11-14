import AnalyticsClient
import ComposableArchitecture
import God
import GodClient
import Styleguide
import SwiftUI

@Reducer
public struct GenderSettingLogic {
  public init() {}

  public struct State: Equatable {
    public init() {}
  }

  public enum Action {
    case onAppear
    case genderButtonTapped(God.Gender)
    case updateUserProfileResponse(TaskResult<God.UpdateUserProfileMutation.Data>)
    case delegate(Delegate)

    public enum Delegate: Equatable {
      case nextScreen
    }
  }

  @Dependency(\.analytics) var analytics
  @Dependency(\.godClient) var godClient

  public var body: some Reducer<State, Action> {
    Reduce<State, Action> { _, action in
      switch action {
      case .onAppear:
        analytics.logScreen(screenName: "GenderSetting", of: self)
        return .none
      case let .genderButtonTapped(gender):
        let input = God.UpdateUserProfileInput(gender: .init(gender))
        analytics.setUserProperty(key: .gender, value: gender.rawValue)
        return .run { send in
          await send(.updateUserProfileResponse(TaskResult {
            try await godClient.updateUserProfile(input)
          }))
        }
      case .updateUserProfileResponse(.success):
        return .send(.delegate(.nextScreen))

      case let .updateUserProfileResponse(.failure(error)):
        print(error)
        return .none

      case .delegate:
        return .none
      }
    }
  }
}

public struct GenderSettingView: View {
  let store: StoreOf<GenderSettingLogic>

  public init(store: StoreOf<GenderSettingLogic>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { _ in
      ZStack {
        Color.godService
          .ignoresSafeArea()

        VStack(spacing: 24) {
          Text("What's your gender?", bundle: .module)
            .foregroundStyle(Color.white)
            .font(.system(.body, design: .rounded, weight: .bold))

          HStack(spacing: 24) {
            ChoiceView(gender: .male) {
              store.send(.genderButtonTapped(.male))
            }
            ChoiceView(gender: .female) {
              store.send(.genderButtonTapped(.female))
            }
          }
          HStack(spacing: 24) {
            ChoiceView(gender: .other) {
              store.send(.genderButtonTapped(.other))
            }
          }
        }
      }
      .onAppear { store.send(.onAppear) }
    }
  }

  struct ChoiceView: View {
    let gender: God.Gender
    let action: () -> Void

    var textGender: LocalizedStringKey {
      switch gender {
      case .female:
        return "Girl"
      case .male:
        return "Boy"
      case .other:
        return "Non-binary"
      }
    }

    var imageNameGender: ImageResource {
      switch gender {
      case .female:
        return ImageResource.girl
      case .male:
        return ImageResource.boy
      case .other:
        return ImageResource.other
      }
    }

    var body: some View {
      Button(action: action) {
        VStack(spacing: 8) {
          Image(imageNameGender)
            .resizable()
            .frame(width: 136, height: 136)
            .background(
              Color.white
                .opacity(0.3)
                .cornerRadius(12)
            )

          Text(textGender, bundle: .module)
            .foregroundStyle(Color.white)
        }
      }
      .buttonStyle(HoldDownButtonStyle())
    }
  }
}
