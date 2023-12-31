import God
import NameImage
import Styleguide
import SwiftUI

public struct ChoiceListSticker: View {
  @State var isAnimation = false

  let questionText: String
  let gender: God.Gender
  let grade: String?
  let avatarImageData: Data?
  let firstName: String
  let choices: [God.InboxFragment.Choice]

  public init(
    questionText: String,
    gender: God.Gender,
    grade: String?,
    avatarImageData: Data?,
    firstName: String,
    choices: [God.InboxFragment.Choice]
  ) {
    self.questionText = questionText
    self.gender = gender
    self.grade = grade
    self.avatarImageData = avatarImageData
    self.firstName = firstName
    self.choices = choices
  }

  public var body: some View {
    VStack(spacing: 0) {
      VStack(spacing: 8) {
        Group {
          if let grade {
            Text("single-from-\(gender.text)-in-\(grade)", bundle: .module)
          } else {
            Text("From a \(gender.text)", bundle: .module)
          }
        }
        .font(.system(.headline, design: .rounded, weight: .bold))
        .foregroundStyle(Color.white)

        Text(questionText)
          .font(.system(.title3, design: .rounded, weight: .bold))
          .foregroundStyle(Color.godBlack)
          .frame(maxWidth: .infinity)
          .padding(.vertical, 8)
          .padding(.horizontal, 12)
          .background(Color.white)
          .cornerRadius(8)
      }
      .padding(.horizontal, 12)
      .padding(.top, 46)
      .padding(.bottom, 12)
      .frame(maxWidth: .infinity)
      .background(gender.color)

      VStack(spacing: 12) {
        ForEach(choices, id: \.self) { choice in
          Text(choice.text)
            .font(.system(.title3, design: .rounded, weight: .bold))
            .frame(height: 48)
            .frame(maxWidth: .infinity)
            .foregroundStyle(choice.isSelected ? Color.white : Color.godBlack.opacity(0.5))
            .background {
              if choice.isSelected {
                gender.color
              } else {
                GeometryReader { proxy in
                  HStack(spacing: 0) {
                    Color(0xFFD1_D5DB)
                      .frame(width: proxy.size.width * Double.random(in: 0.1 ..< 0.4))
                      .opacity(0.5)
                    Color.white
                  }
                }
              }
            }
            .clipShape(Capsule())
            .overlay {
              if !choice.isSelected {
                RoundedRectangle(cornerRadius: 48 / 2)
                  .stroke(Color(0xFFD1_D5DB), lineWidth: 1)
                  .opacity(0.5)
              }
            }
            .overlay(alignment: .topTrailing) {
              if choice.isSelected {
                Image(gender.finger)
                  .offset(x: 30, y: -24)
                  .scaleEffect(isAnimation ? 1.0 : 0.9)
                  .animation(
                    .default.repeatForever(autoreverses: true).speed(0.5),
                    value: isAnimation
                  )
                  .task {
                    isAnimation = true
                  }
              }
            }
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
      Group {
        if let avatarImageData, let image = UIImage(data: avatarImageData) {
          Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 64, height: 64)
        } else {
          NameImage(name: firstName, size: 64)
        }
      }
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
      grade: "1年生",
      avatarImageData: nil,
      firstName: "Tomoki",
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
        Color(0xFFB3_94FF),
        Color(0xFFFF_A3E5),
        Color(0xFFFF_E39B),
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
