import ButtonStyles
import Colors
import ComposableArchitecture
import God
import GodClient
import SwiftUI

public struct GenderSettingLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    public init() {}
  }

  public enum Action: Equatable {
    case genderButtonTapped(God.Gender)
    case updateUserProfileResponse(TaskResult<God.UpdateUserProfileMutation.Data>)
    case delegate(Delegate)

    public enum Delegate: Equatable {
      case nextScreen
    }
  }

  @Dependency(\.godClient) var godClient

  public var body: some Reducer<State, Action> {
    Reduce<State, Action> { _, action in
      switch action {
      case let .genderButtonTapped(gender):
        let input = God.UpdateUserProfileInput(gender: .init(gender))
        return .run { send in
          await send(
            .updateUserProfileResponse(
              TaskResult {
                try await godClient.updateUserProfile(input)
              }
            )
          )
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
    WithViewStore(store, observe: { $0 }) { viewStore in
      ZStack {
        Color.godService
          .ignoresSafeArea()

        VStack(spacing: 24) {
          Text("What's your gender?", bundle: .module)
            .bold()
            .foregroundColor(Color.white)

          HStack(spacing: 24) {
            ChoiceView(gender: .male) {
              viewStore.send(.genderButtonTapped(.male))
            }
            ChoiceView(gender: .female) {
              viewStore.send(.genderButtonTapped(.female))
            }
          }
          HStack(spacing: 24) {
            ChoiceView(gender: .other) {
              viewStore.send(.genderButtonTapped(.other))
            }
          }
        }
      }
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
            .foregroundColor(Color.white)
        }
      }
      .buttonStyle(HoldDownButtonStyle())
    }
  }
}

struct GenderSettingViewPreviews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      GenderSettingView(
        store: .init(
          initialState: GenderSettingLogic.State(),
          reducer: { GenderSettingLogic() }
        )
      )
    }
  }
}
