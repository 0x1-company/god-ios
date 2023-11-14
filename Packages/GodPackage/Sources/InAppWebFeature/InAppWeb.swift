import AnalyticsClient
import ComposableArchitecture
import Styleguide
import SwiftUI
import WebKit

@Reducer
public struct InAppWebLogic {
  public init() {}

  public struct State: Equatable {
    let url: URL

    public init(url: URL) {
      self.url = url
    }
  }

  public enum Action: Equatable {
    case onTask
    case onAppear
    case closeButtonTapped
  }

  @Dependency(\.dismiss) var dismiss
  @Dependency(\.analytics) var analytics

  public var body: some Reducer<State, Action> {
    Reduce<State, Action> { _, action in
      switch action {
      case .onTask:
        return .none

      case .onAppear:
        analytics.logScreen(screenName: "InAppWeb", of: self)
        return .none

      case .closeButtonTapped:
        return .run { _ in
          await dismiss()
        }
      }
    }
  }
}

public struct InAppWebView: View {
  let store: StoreOf<InAppWebLogic>

  public init(store: StoreOf<InAppWebLogic>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      NavigationStack {
        WebView(url: viewStore.url)
          .ignoresSafeArea()
          .navigationBarTitleDisplayMode(.inline)
          .toolbarBackground(Color.godBlack, for: .navigationBar)
          .task { await store.send(.onTask).finish() }
          .onAppear { store.send(.onAppear) }
          .toolbar {
            ToolbarItem(placement: .topBarLeading) {
              Button {
                store.send(.closeButtonTapped)
              } label: {
                Image(systemName: "xmark")
                  .foregroundStyle(Color.white)
              }
            }
          }
      }
    }
  }

  struct WebView: UIViewRepresentable {
    typealias UIViewType = WKWebView
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
      let webView = WKWebView(frame: .zero)
      webView.load(URLRequest(url: url))
      return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
  }
}

#Preview {
  Color.clear
    .sheet(isPresented: .constant(true)) {
      InAppWebView(
        store: .init(
          initialState: InAppWebLogic.State(
            url: URL(string: "https://docs.godapp.jp")!
          ),
          reducer: { InAppWebLogic() }
        )
      )
    }
}
