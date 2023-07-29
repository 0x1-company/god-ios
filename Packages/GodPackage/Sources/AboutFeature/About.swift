import ComposableArchitecture
import SwiftUI

public struct AboutReducer: ReducerProtocol {
  public init() {}

  public struct State: Equatable {
    public init() {}
  }

  public enum Action: Equatable {
    case howItWorksButtonTapped
    case faqButtonTapped
    case shareFeedbackButtonTapped
    case getHelpButtonTapped
    case safetyCenterButtonTapped
  }

  public var body: some ReducerProtocol<State, Action> {
    Reduce { _, action in
      switch action {
      case .howItWorksButtonTapped:
        return .none

      case .faqButtonTapped:
        return .none

      case .shareFeedbackButtonTapped:
        return .none

      case .getHelpButtonTapped:
        return .none

      case .safetyCenterButtonTapped:
        return .none
      }
    }
  }
}

public struct AboutView: View {
  let store: StoreOf<AboutReducer>

  public init(store: StoreOf<AboutReducer>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      ScrollView(.vertical) {
        VStack(alignment: .center, spacing: 24) {
          IconButton("How It Works", name: "") {
            viewStore.send(.howItWorksButtonTapped)
          }
          IconButton("FAQ", name: "clipboard") {
            viewStore.send(.faqButtonTapped)
          }
          IconButton("Share Feedback", name: "megaphone") {
            viewStore.send(.shareFeedbackButtonTapped)
          }
          IconButton("Get Help", name: "rescue-workers-helmet") {
            viewStore.send(.getHelpButtonTapped)
          }
          IconButton("Safety Center", name: "shield") {
            viewStore.send(.safetyCenterButtonTapped)
          }
        }
        .padding(.top, 24)
        .padding(.horizontal, 32)
      }
    }
  }
}

struct AboutViewPreviews: PreviewProvider {
  static var previews: some View {
    AboutView(
      store: .init(
        initialState: AboutReducer.State(),
        reducer: AboutReducer()
      )
    )
  }
}
