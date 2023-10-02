import ButtonStyles
import Colors
import ComposableArchitecture
import God
import GodClient
import ProfilePicture
import SwiftUI
import UIApplicationClient
import UIPasteboardClient

public struct HowToShareOnInstagramLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    public enum Step: Int, CaseIterable {
      case one = 1
      case two = 2
      case three = 3
      case four = 4

      var primaryButtonText: LocalizedStringKey {
        switch self {
        case .one, .two, .three:
          return "Next Step"
        case .four:
          return "Share on Instagram"
        }
      }

      var descriptionImageName: String {
        "how-tow-share-on-instagram-\(rawValue)"
      }
    }

    var currentUser: God.CurrentUserQuery.Data.CurrentUser?
    var allSteps: [Step] = Step.allCases
    var currentStep: Step = .one
    public init() {}
  }

  public enum Action: Equatable {
    case onTask
    case currentUserResponse(TaskResult<God.CurrentUserQuery.Data>)
    case stepButtonTapped(State.Step)
    case primaryButtonTapped(profileCardImage: UIImage? = nil)
    case closeButtonTapped
  }

  @Dependency(\.dismiss) var dismiss
  @Dependency(\.openURL) var openURL
  @Dependency(\.godClient) var godClient
  @Dependency(\.pasteboard) var pasteboard

  public var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .onTask:
        return .run { send in
          for try await data in godClient.currentUser() {
            await send(.currentUserResponse(.success(data)))
          }
        } catch: { error, send in
          await send(.currentUserResponse(.failure(error)))
        }

      case let .currentUserResponse(.success(data)):
        state.currentUser = data.currentUser
        return .none

      case .currentUserResponse(.failure):
        return .run { _ in
          await dismiss()
        }

      case let .stepButtonTapped(step):
        state.currentStep = step
        return .none

      case let .primaryButtonTapped(profileCardImage) where state.currentStep == State.Step.allCases.last:
        guard
          let storiesURL = URL(string: "instagram-stories://share?source_application=1049646559806019"),
          let profileCardImage,
          let imageData = profileCardImage.pngData()
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
        return .run { _ in
          await openURL(storiesURL)
          await dismiss()
        }

      case .primaryButtonTapped:
        guard let nextStep = State.Step(rawValue: state.currentStep.rawValue + 1)
        else { return .none }
        state.currentStep = nextStep
        return .none

      case .closeButtonTapped:
        return .run { _ in
          await dismiss()
        }
      }
    }
  }
}

public struct HowToShareOnInstagramView: View {
  public static let heightForPresentationDetents: CGFloat = 260
  let store: StoreOf<HowToShareOnInstagramLogic>

  @Environment(\.displayScale) var displayScale

  public init(store: StoreOf<HowToShareOnInstagramLogic>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      let profileCardForShareOnInstagram = profileCardForShareOnInstagram(user: viewStore.currentUser)
      ZStack(alignment: .center) {
        // instagramへのシェア用のView
        profileCardForShareOnInstagram

        VStack(alignment: .center, spacing: 24) {
          Text("How to add the\nlink to your Story", bundle: .module)
            .font(.title)
            .bold()
            .foregroundColor(.godBlack)
            .multilineTextAlignment(.center)

          HStack(alignment: .center, spacing: 12) {
            ForEach(viewStore.allSteps, id: \.rawValue) { step in
              Button {
                viewStore.send(.stepButtonTapped(step))
              } label: {
                Text(String(step.rawValue))
                  .font(.subheadline)
                  .foregroundColor(viewStore.state.currentStep == step ? .godWhite : .godBlack)
                  .frame(width: 36, height: 36)
                  .background(viewStore.state.currentStep == step ? Color.godBlack : Color.godWhite)
                  .cornerRadius(18)
                  .overlay(
                    viewStore.state.currentStep == step ? nil :
                      Circle()
                      .stroke(Color.godBlack, lineWidth: 0.5)
                  )
              }
              .buttonStyle(HoldDownButtonStyle())
            }
          }

          RoundedRectangle(cornerRadius: 24)
            .fill(Color.red)
            .frame(maxWidth: .infinity)
            .frame(height: 240)

          Button {
            let renderer = ImageRenderer(content: profileCardForShareOnInstagram)
            renderer.scale = displayScale
            viewStore.send(.primaryButtonTapped(profileCardImage: renderer.uiImage))
          } label: {
            Text(viewStore.currentStep.primaryButtonText, bundle: .module)
              .bold()
              .foregroundColor(.godWhite)
              .frame(maxWidth: .infinity)
              .frame(height: 52)
              .background(Color.godService)
              .cornerRadius(26)
          }
          .buttonStyle(HoldDownButtonStyle())
        }
        .padding(20)
        .background(Color.godWhite)
        .cornerRadius(24)
      }
      .task { await viewStore.send(.onTask).finish() }
    }
  }

  @ViewBuilder
  private func profileCardForShareOnInstagram(user: God.CurrentUserQuery.Data.CurrentUser?) -> some View {
    if let user {
      VStack(alignment: .center, spacing: 0) {
        VStack(alignment: .center, spacing: 24) {
          ProfilePicture(
            url: URL(string: user.imageURL),
            familyName: user.lastName,
            givenName: user.firstName,
            size: 90
          )

          VStack(alignment: .center, spacing: 0) {
            Text(user.displayName.ja)
              .font(.headline)
              .bold()
              .foregroundStyle(Color.godWhite)

            Text(verbatim: "@\(user.username ?? "")")
              .font(.body)
              .foregroundStyle(Color.godTextSecondaryLight)
          }

          VStack(alignment: .center, spacing: 0) {
            Text("Add me on", bundle: .module)
              .font(.title2)
              .fontWeight(.heavy)
              .foregroundStyle(Color.godWhite)
            Image("god-icon-white", bundle: .module)
              .resizable()
              .aspectRatio(contentMode: .fit)
              .frame(height: 24)
              .foregroundStyle(Color.godWhite)
              .padding(.bottom, 4)
            Text(verbatim: "godapp.jp")
              .font(.callout)
              .bold()
              .foregroundColor(.godWhite)
          }
          .padding(.bottom, 8)

          HStack(alignment: .center, spacing: 4) {
            Circle()
              .fill(Color.godGreen)
              .frame(width: 36, height: 36)

            (
              Text("1053 people ").bold() +
                Text("from\n\(user.school?.name ?? "")")
            )
            .foregroundStyle(Color.godWhite)
            .font(.footnote)
            .lineLimit(2)
            .multilineTextAlignment(.leading)
          }
          .frame(maxWidth: .infinity, alignment: .center)
          .frame(height: 48)
          .background(Color(red: 30 / 255, green: 30 / 255, blue: 30 / 255))
        }
        .padding(.top, 32)
        .background(Color(red: 35 / 255, green: 35 / 255, blue: 35 / 255))
        .cornerRadius(16)
        .clipShape(RoundedRectangle(cornerRadius: 8))
      }
      .frame(maxWidth: .infinity)
      .padding(.horizontal, 24)
      .background(Color.clear)
    }
  }
}

#Preview {
  Color.red
    .sheet(
      isPresented: .constant(true)
    ) {
      HowToShareOnInstagramView(
        store: .init(
          initialState: HowToShareOnInstagramLogic.State(),
          reducer: { HowToShareOnInstagramLogic() }
        )
      )
      .presentationDetents([.fraction(0.3)])
      .presentationDragIndicator(.visible)
    }
}
