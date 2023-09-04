import Colors
import SwiftUI

public struct TopStarsSection: View {
  public var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      Text("Top Stars")
        .font(.headline)
        .bold()
        .frame(height: 32)
        .padding(.horizontal, 16)

      Divider()

      //      ForEach(Self.mockTopFlames, id: \.rank) { flame in
      //        HStack(alignment: .center, spacing: 12) {
      //          RoundedRectangle(cornerRadius: 4)
      //            .fill(Color.blue)
      //            .frame(width: 60, height: 60)
      //            .overlay(
      //              Circle()
      //                .fill(Color.red)
      //                .frame(width: 20, height: 20),
      //              alignment: .bottomLeading
      //            )
      //
      //          Text(flame.questionText)
      //            .font(.body)
      //            .multilineTextAlignment(.leading)
      //            .lineLimit(2)
      //        }
      //        .frame(height: 84)
      //        .padding(.horizontal, 16)
      //
      //      Divider()
      //    }
    }
    .background(Color.godWhite)
  }
}
