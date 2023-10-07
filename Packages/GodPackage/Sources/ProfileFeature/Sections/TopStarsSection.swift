import Colors
import God
import CachedAsyncImage
import SwiftUI

public struct TopStarsSection: View {
  let questions: [God.CurrentUserProfileQuery.Data.QuestionsOrderByVotedDesc]

  public var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      Text("Top Stars", bundle: .module)
        .font(.headline)
        .bold()
        .frame(height: 32)
        .padding(.horizontal, 16)

      Divider()

      ForEach(Array(questions.enumerated()), id: \.offset) { offset, question in
        HStack(spacing: 12) {
          CachedAsyncImage(
            url: URL(string: question.imageURL),
            content: { image in
              image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 60, height: 60)
                .clipped()
                .overlay(alignment: .bottomLeading) {
                                Image("digit-\(offset + 1)", bundle: .module)
                                  .resizable()
                                  .scaledToFit()
                                  .frame(width: 20, height: 20)
                                  .clipShape(Circle())
                }
            },
            placeholder: {
              ProgressView()
                .progressViewStyle(.circular)
            }
          )

          Text(question.text.ja)
            .multilineTextAlignment(.leading)
        }
        .frame(height: 84)

        Divider()
      }
      .padding(.horizontal, 16)
    }
    .background(.white)
  }
}
