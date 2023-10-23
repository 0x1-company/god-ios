import ComposableArchitecture
import SwiftUI

public struct ContactsReEnableLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    public init() {}
  }

  public enum Action: Equatable {
    case onTapGesture
  }

  @Dependency(\.openURL) var openURL
  @Dependency(\.application.openSettingsURLString) var openSettingsURLString

  public var body: some Reducer<State, Action> {
    Reduce<State, Action> { _, action in
      switch action {
      case .onTapGesture:
        return .run { _ in
          let settingsURLString = await openSettingsURLString()
          guard let url = URL(string: settingsURLString)
          else { return }
          await openURL(url)
        }
      }
    }
  }
}

public struct ContactsReEnableView: View {
  let store: StoreOf<ContactsReEnableLogic>

  public init(store: StoreOf<ContactsReEnableLogic>) {
    self.store = store
  }

  public var body: some View {
    VStack(spacing: 0) {
      HStack(spacing: 16) {
        Image(systemName: "person.crop.square.fill")
          .font(.system(size: 30))
        VStack(alignment: .leading, spacing: 4) {
          Text("Contacts are disabled", bundle: .module)
            .font(.system(.body, design: .rounded, weight: .bold))
          Text("Tap to re-enable", bundle: .module)
            .foregroundStyle(Color.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        Image(systemName: "chevron.right")
      }
      .frame(height: 70)
      .padding(.horizontal, 16)
      .foregroundColor(.white)
      .background(Color.godService)
    }
    .onTapGesture {
      store.send(.onTapGesture)
    }
  }
}

#Preview {
  ContactsReEnableView(
    store: .init(
      initialState: ContactsReEnableLogic.State(),
      reducer: { ContactsReEnableLogic() }
    )
  )
}
