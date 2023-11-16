import God
import SwiftUI

public struct ChoiceListSticker: View {
  let questionText: String
  let gender: God.Gender
  let grade: String?
  let choices: [God.InboxFragment.Choice]
  
  public init(
    questionText: String,
    gender: God.Gender,
    grade: String?,
    choices: [God.InboxFragment.Choice]
  ) {
    self.questionText = questionText
    self.gender = gender
    self.grade = grade
    self.choices = choices
  }

  public var body: some View {
    VStack(spacing: 0) {
      VStack(spacing: 8) {
        Group {
          if let grade {
            Text("From a \(gender.text) in \(grade)", bundle: .module)
          } else {
            Text("From a \(gender.text)", bundle: .module)
          }
        }
        .font(.system(.headline, design: .rounded, weight: .bold))
        .foregroundStyle(Color.white)
        
        Text(questionText)
          .font(.system(.title3, design: .rounded, weight: .bold))
          .foregroundStyle(gender.color)
          .frame(maxWidth: .infinity)
          .padding(.vertical, 8)
          .padding(.horizontal, 12)
          .background(Color.white)
          .cornerRadius(8)
      }
      .padding(.horizontal, 12)
      .padding(.top, 42)
      .padding(.bottom, 12)
      .frame(maxWidth: .infinity)
      .background(gender.color)
      
      VStack(spacing: 12) {
        ForEach(choices, id: \.self) { choice in
          Group {
            if choice.text.isEmpty {
              Color.white
                .opacity(0.5)
                .frame(height: 18)
                .clipShape(Capsule())
                .padding(.horizontal, 24)
            } else {
              Text(choice.text)
            }
          }
          .font(.system(.title3, design: .rounded, weight: .bold))
          .frame(height: 48)
          .frame(maxWidth: .infinity)
          .foregroundStyle(Color.white)
          .background(gender.color)
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
  VStack(spacing: 0) {
    ChoiceListSticker(
      questionText: "かけてあるバックの持ち手が片方だけ外れてたら、そっと治す",
      gender: God.Gender.female,
      grade: "11th grade",
      choices: [
        God.InboxFragment.Choice(
          _dataDict: DataDict(
            data: [
              "isSelected": 1,
              "text": "やまだ たろう",
            ],
            fulfilledFragments: []
          )
        ),
        God.InboxFragment.Choice(
          _dataDict: DataDict(
            data: [
              "isSelected": 0,
              "text": "まつし れん",
            ],
            fulfilledFragments: []
          )
        ),
        God.InboxFragment.Choice(
          _dataDict: DataDict(
            data: [
              "isSelected": 0,
              "text": "たんまつ てすと",
            ],
            fulfilledFragments: []
          )
        ),
        God.InboxFragment.Choice(
          _dataDict: DataDict(
            data: [
              "isSelected": 0,
              "text": "",
            ],
            fulfilledFragments: []
          )
        ),
      ]
    )
  }
  .padding(.horizontal, 48)
  .frame(maxWidth: .infinity, maxHeight: .infinity)
  .background(
    LinearGradient(
      colors: [
        Color(0xFFB394FF),
        Color(0xFFFFA3E5),
        Color(0xFFFFE39B),
      ],
      startPoint: UnitPoint(x: 0.5, y: 0.0),
      endPoint: UnitPoint(x: 0.5, y: 1.0)
    )
  )
  .overlay(alignment: .bottom) {
    VStack(spacing: 4) {
      Image(ImageResource.icon)
      Text("See who likes you - God", bundle: .module)
        .font(.system(.body, design: .rounded, weight: .medium))
    }
  }
  .environment(\.locale, Locale(identifier: "ja-JP"))
}
