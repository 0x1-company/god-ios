import Styleguide
import SwiftUI

public struct SocialShare: View {
  let shareURL: URL
  let storyAction: () -> Void
  let lineAction: () -> Void
  let messageAction: () -> Void
  
  public init(
    shareURL: URL,
    storyAction: @escaping () -> Void,
    lineAction: @escaping () -> Void,
    messageAction: @escaping () -> Void
  ) {
    self.shareURL = shareURL
    self.storyAction = storyAction
    self.lineAction = lineAction
    self.messageAction = messageAction
  }

  public var body: some View {
    HStack(spacing: 0) {
      Button(action: storyAction) {
        VStack(spacing: 12) {
          Image(ImageResource.instagram)
            .resizable()
            .aspectRatio(1, contentMode: .fit)
            .frame(width: 56, height: 56)
            .clipShape(Circle())

          Text("Story", bundle: .module)
            .font(.system(.callout, design: .rounded, weight: .bold))
        }
      }

      Spacer()

      Button(action: lineAction) {
        VStack(spacing: 12) {
          Image(ImageResource.line)
            .resizable()
            .aspectRatio(1, contentMode: .fit)
            .frame(width: 56, height: 56)
            .clipShape(Circle())

          Text("LINE", bundle: .module)
            .font(.system(.callout, design: .rounded, weight: .bold))
        }
      }

      Spacer()

      Button(action: messageAction) {
        VStack(spacing: 12) {
          Image(systemName: "message.fill")
            .font(.system(size: 34))
            .frame(width: 56, height: 56)
            .foregroundStyle(Color.white)
            .background(Color.green.gradient)
            .clipShape(Circle())

          Text("Message", bundle: .module)
            .font(.system(.callout, design: .rounded, weight: .bold))
        }
      }

      Spacer()

      ShareLink(item: shareURL) {
        VStack(spacing: 12) {
          Image(systemName: "square.and.arrow.up")
            .font(.system(size: 34))
            .frame(width: 56, height: 56)
            .clipShape(Circle())

          Text("Other", bundle: .module)
            .font(.system(.callout, design: .rounded, weight: .bold))
        }
      }
    }
    .buttonStyle(HoldDownButtonStyle())
  }
}

#Preview {
  SocialShare(
    shareURL: URL(string: "https://godapp.jp")!,
    storyAction: {},
    lineAction: {},
    messageAction: {}
  )
  .padding(.horizontal, 24)
}
