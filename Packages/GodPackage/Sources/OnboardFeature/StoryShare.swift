import Constants
import ComposableArchitecture
import Styleguide
import SwiftUI
import UIPasteboardClient
import ProfileStoryFeature

public struct StoryShareLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    public init() {}
  }

  public enum Action: Equatable {
    case onTask
    case onAppear
    case nextButtonTapped
    case shareStoriesButtonTapped(UIImage?)
  }
  
  @Dependency(\.openURL) var openURL
  @Dependency(\.pasteboard) var pasteboard

  public var body: some Reducer<State, Action> {
    Reduce<State, Action> { _, action in
      switch action {
      case .onTask:
        return .none
        
      case .onAppear:
        return .none
        
      case .nextButtonTapped:
        return .none
        
      case let .shareStoriesButtonTapped(.some(profileCardImage)):
        guard let imageData = profileCardImage.pngData()
        else { return .none }
        let pasteboardItems: [String: Any] = [
          "com.instagram.sharedSticker.stickerImage": imageData,
          "com.instagram.sharedSticker.backgroundTopColor": "#000000",
          "com.instagram.sharedSticker.backgroundBottomColor": "#000000",
        ]
        pasteboard.setItems(
          [pasteboardItems],
          [.expirationDate: Date().addingTimeInterval(300)]
        )
        return .run { send in
          await openURL(Constants.storiesURL)
        }
      default:
        return .none
      }
    }
  }
}

public struct StoryShareView: View {
  let store: StoreOf<StoryShareLogic>
  @Environment(\.displayScale) var displayScale

  public init(store: StoreOf<StoryShareLogic>) {
    self.store = store
  }
  
  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      let instagramStoryView = ProfileStoryView(
        profileImageData: nil,
        firstName: "tomoki",
        displayName: "tomoki",
        username: "tomokisun",
        schoolImageData: nil,
        schoolName: nil
      )
      VStack(spacing: 0) {
        Spacer()
        
        instagramStoryView
        
        Spacer()
        
        Button {
          let renderer = ImageRenderer(content: instagramStoryView)
          renderer.scale = displayScale
          store.send(.shareStoriesButtonTapped(renderer.uiImage))
        } label: {
          Text("Share Stories", bundle: .module)
            .foregroundStyle(Color.white)
            .font(.system(.title3, design: .rounded, weight: .heavy))
            .frame(height: 54)
            .frame(maxWidth: .infinity)
            .background(Color.white.opacity(0.2))
            .clipShape(Capsule())
            .overlay(alignment: .leading) {
              Image(ImageResource.instagram)
                .resizable()
                .aspectRatio(1, contentMode: .fit)
                .frame(width: 32, height: 32)
                .padding(.leading, 16)
            }
        }
        .buttonStyle(HoldDownButtonStyle())
      }
      .padding(.horizontal, 24)
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(Color.black)
      .navigationTitle(Text("Story Share", bundle: .module))
      .navigationBarTitleDisplayMode(.inline)
      .toolbarBackground(Color.godService, for: .navigationBar)
      .toolbarBackground(.visible, for: .navigationBar)
      .toolbarColorScheme(.dark, for: .navigationBar)
      .task { await store.send(.onTask).finish() }
      .onAppear { store.send(.onAppear) }
      .toolbar {
        Button {
          store.send(.nextButtonTapped)
        } label: {
          Text("Next", bundle: .module)
            .foregroundColor(Color.white)
            .font(.system(.body, design: .rounded, weight: .bold))
        }
        .buttonStyle(HoldDownButtonStyle())
      }
    }
  }
}

#Preview {
  NavigationStack {
    StoryShareView(
      store: .init(
        initialState: StoryShareLogic.State(),
        reducer: { StoryShareLogic() }
      )
    )
  }
  .environment(\.locale, Locale(identifier: "ja-JP"))
}
