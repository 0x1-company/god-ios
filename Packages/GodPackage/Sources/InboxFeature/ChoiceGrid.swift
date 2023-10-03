import God
import SwiftUI

struct ChoiceGrid: View {
  let color: Color
  let choices: [God.InboxFragment.Choice]

  var body: some View {
    LazyVGrid(
      columns: Array(repeating: GridItem(spacing: 16), count: 2),
      spacing: 16
    ) {
      ForEach(choices, id: \.self) { choice in
        Text(verbatim: choice.text)
          .font(.callout)
          .bold()
          .lineLimit(2)
          .multilineTextAlignment(.center)
          .padding(.horizontal, 16)
          .frame(height: 64)
          .frame(maxWidth: .infinity, alignment: .center)
          .foregroundStyle(color)
          .background(
            Color.godWhite
          )
          .cornerRadius(8)
          .opacity(choice.isSelected ? 1 : 0.6)
          .overlay(alignment: .topTrailing) {
            if choice.isSelected {
              Image(ImageResource.fingerIcon)
                .resizable()
                .frame(width: 48, height: 48)
                .rotationEffect(.degrees(-30))
                .shadow(color: color, radius: 8)
                .offset(x: 20, y: -20)
            }
          }
      }
    }
  }
}
