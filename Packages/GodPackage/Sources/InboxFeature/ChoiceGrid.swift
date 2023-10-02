import SwiftUI

struct ChoiceGrid: View {
  let color: Color
  let choices: [String]
  let selectedChoice: String
  
  var body: some View {
    LazyVGrid(
      columns: Array(repeating: GridItem(spacing: 16), count: 2),
      spacing: 16
    ) {
      ForEach(choices, id: \.self) { choice in
        let isSelectedUser: Bool = choice == selectedChoice
        Text(verbatim: choice)
          .font(.callout)
          .bold()
          .lineLimit(2)
          .multilineTextAlignment(.leading)
          .padding(.horizontal, 16)
          .frame(height: 64)
          .frame(maxWidth: .infinity, alignment: .leading)
          .foregroundStyle(color)
          .background(
            Color.godWhite
          )
          .cornerRadius(8)
          .opacity(isSelectedUser ? 1 : 0.6)
          .overlay(alignment: .topTrailing) {
            if isSelectedUser {
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
