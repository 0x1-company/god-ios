import Styleguide
import SwiftUI

public struct ReceivedSticker: View {
  let questionText: String
  
  public init(
    questionText: String
  ) {
    self.questionText = questionText
  }
  
  public var body: some View {
    VStack(spacing: 0) {
      Text("From a boy in 11th grade")
        .font(.system(.headline, design: .rounded, weight: .bold))
        .padding(.horizontal, 12)
        .padding(.top, 36)
        .padding(.bottom, 12)
        .frame(maxWidth: .infinity, minHeight: 90)
        .foregroundStyle(Color.white)
        .background(Color(0xFF00C7FE))
      
      Text(questionText)
        .font(.system(.headline, design: .rounded, weight: .bold))
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity, minHeight: 90)
        .background(Color.white)
    }
    .cornerRadius(24)
    .multilineTextAlignment(.center)
    .overlay {
      RoundedRectangle(cornerRadius: 24)
        .stroke(Color.white, lineWidth: 4)
    }
    .overlay(alignment: .top) {
      HStack(spacing: 8) {
        Color.white
          .frame(width: 64, height: 64)
          .clipShape(Circle())
          .overlay {
            Image(systemName: "person.fill")
              .foregroundStyle(Color(0xFF00C7FE))
              .font(.system(size: 42, weight: .bold))
          }
          .overlay(alignment: .bottomTrailing) {
            Image(systemName: "questionmark")
              .foregroundStyle(Color(0xFF00C7FE))
              .frame(width: 24, height: 24)
              .font(.system(size: 14, weight: .bold))
              .background(Color.white)
              .clipShape(Circle())
              .overlay(
                RoundedRectangle(cornerRadius: 24 / 2)
                  .stroke(Color(0xFF00C7FE), lineWidth: 2)
              )
          }
        
        Image(ImageResource.arrowRight)
          .offset(y: -4)
        
        Color.red
          .frame(width: 64, height: 64)
          .clipShape(Circle())
          .overlay(
            RoundedRectangle(cornerRadius: 64 / 2)
              .stroke(Color.white, lineWidth: 4)
          )
      }
      .offset(y: -27)
    }
  }
}

#Preview {
  ReceivedSticker(
    questionText: "Your ideal study buddy"
  )
}
