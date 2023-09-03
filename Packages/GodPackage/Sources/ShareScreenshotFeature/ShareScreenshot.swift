import ComposableArchitecture
import SwiftUI

public struct ShareScreenshotLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    public init() {}
  }

  public enum Action: Equatable {
    case lineButtonTapped
    case instagramButtonTapped
    case messagesButtonTapped
  }

  public var body: some Reducer<State, Action> {
    Reduce { _, action in
      switch action {
      case .lineButtonTapped:
        return .none

      case .instagramButtonTapped:
        return .none

      case .messagesButtonTapped:
        return .none
      }
    }
  }
}

public struct ShareScreenshotView: View {
  let store: StoreOf<ShareScreenshotLogic>

  public init(store: StoreOf<ShareScreenshotLogic>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      HStack(alignment: .top, spacing: 20) {
        Color.red
          .frame(width: 91, height: 184)
          .cornerRadius(16)
          .padding(.top, 12)

        VStack(spacing: 36) {
          Text("Share Screenshot")
            .font(.title3)
            .bold()

          HStack(spacing: 8) {
            Button {
              viewStore.send(.instagramButtonTapped)
            } label: {
              VStack(spacing: 8) {
                Color.red
                  .frame(width: 50, height: 50)
                  .clipShape(Circle())
                Text("Instagram")
              }
            }

            Button {
              viewStore.send(.lineButtonTapped)
            } label: {
              VStack(spacing: 8) {
                Color.green
                  .frame(width: 50, height: 50)
                  .clipShape(Circle())
                Text("LINE")
              }
            }

            Button {
              viewStore.send(.messagesButtonTapped)
            } label: {
              VStack(spacing: 8) {
                Color.green
                  .frame(width: 50, height: 50)
                  .clipShape(Circle())
                Text("Messages")
              }
            }
          }
          .foregroundColor(.primary)

          Spacer()
        }
      }
      .padding(.top, 24)
    }
  }
}

struct ShareScreenshotViewPreviews: PreviewProvider {
  static var previews: some View {
    Text("a")
      .sheet(isPresented: .constant(true)) {
        ShareScreenshotView(
          store: .init(
            initialState: ShareScreenshotLogic.State(),
            reducer: { ShareScreenshotLogic() }
          )
        )
        .presentationDetents([.fraction(0.3)])
        .presentationDragIndicator(.visible)
      }
  }
}
