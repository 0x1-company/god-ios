import SwiftUI

public struct ChoiceListSticker: View {
  let questionText: String
  
  public init(
    questionText: String
  ) {
    self.questionText = questionText
  }

  public var body: some View {
    VStack(spacing: 0) {
      VStack(spacing: 8) {
        Text("From a boy in 11th grade")
          .font(.system(.headline, design: .rounded, weight: .bold))
          .foregroundStyle(Color.white)
        
        Text(questionText)
          .font(.system(.title3, design: .rounded, weight: .bold))
          .foregroundStyle(Color(0xFF00C7FE))
          .frame(maxWidth: .infinity)
          .padding(.vertical, 8)
          .background(Color.white)
          .cornerRadius(8)
      }
      .padding(.horizontal, 12)
      .padding(.top, 42)
      .padding(.bottom, 12)
      .frame(maxWidth: .infinity)
      .background(Color(0xFF00C7FE))
      
      VStack(spacing: 12) {
        ForEach(0..<4, id: \.self) { _ in
          Text("tomokisun")
            .font(.system(.title3, design: .rounded, weight: .bold))
            .frame(height: 48)
            .frame(maxWidth: .infinity)
            .foregroundStyle(Color.white)
            .background(Color(0xFF00C7FE))
            .clipShape(Capsule())
        }
      }
      .padding(.vertical, 18)
      .padding(.horizontal, 16)
      .frame(maxWidth: .infinity)
      .background(Color.white)
    }
    .cornerRadius(24)
    .multilineTextAlignment(.center)
    .overlay {
      RoundedRectangle(cornerRadius: 24)
        .stroke(Color.white, lineWidth: 4)
    }
    .overlay(alignment: .top) {
      Color.red
        .frame(width: 64, height: 64)
        .clipShape(Circle())
        .overlay(
          RoundedRectangle(cornerRadius: 64 / 2)
            .stroke(Color.white, lineWidth: 4)
        )
        .offset(y: -27)
    }
  }
}

#Preview {
  ChoiceListSticker(
    questionText: "Your ideal study buddy"
  )
}
