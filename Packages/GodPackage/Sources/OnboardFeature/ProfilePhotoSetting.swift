import ComposableArchitecture
import SwiftUI

public struct ProfilePhotoSettingReducer: Reducer {
  public init() {}

  public struct State: Equatable {
    public init() {}
  }

  public enum Action: Equatable {
    case choosePhotoButtonTapped
    case takePhotoButtonTapped
  }

  public var body: some ReducerOf<Self> {
    Reduce { _, action in
      switch action {
      case .choosePhotoButtonTapped:
        return .none

      case .takePhotoButtonTapped:
        return .none
      }
    }
  }
}

public struct ProfilePhotoSettingView: View {
  let store: StoreOf<ProfilePhotoSettingReducer>

  public init(store: StoreOf<ProfilePhotoSettingReducer>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      VStack(spacing: 12) {
        Spacer()

        Text("Add a profile photo")
          .bold()
          .foregroundColor(Color.white)
        
        Color.red
          .frame(width: 120, height: 120)
          .clipShape(Circle())
        
        Text("Add a photo so your friends can find you")
          .foregroundColor(.secondary)

        Spacer()

        Button {
          viewStore.send(.choosePhotoButtonTapped)
        } label: {
          Text("Choose a photo")
            .bold()
            .frame(height: 56)
            .frame(maxWidth: .infinity)
        }
        .foregroundColor(Color.white)
        .overlay(
          RoundedRectangle(cornerRadius: 56 / 2)
            .stroke(Color.white, lineWidth: 1)
        )
        
        Button {
          viewStore.send(.takePhotoButtonTapped)
        } label: {
          Text("Take a photo")
            .bold()
            .frame(height: 56)
            .frame(maxWidth: .infinity)
        }
        .foregroundColor(Color.white)
        .overlay(
          RoundedRectangle(cornerRadius: 56 / 2)
            .stroke(Color.white, lineWidth: 1)
        )
      }
      .padding(.horizontal, 24)
      .background(Color.orange)
      .toolbar {
        Button("Skip") {}
      }
    }
  }
}

struct ProfilePhotoSettingViewPreviews: PreviewProvider {
  static var previews: some View {
    ProfilePhotoSettingView(
      store: .init(
        initialState: ProfilePhotoSettingReducer.State(),
        reducer: { ProfilePhotoSettingReducer() }
      )
    )
  }
}
