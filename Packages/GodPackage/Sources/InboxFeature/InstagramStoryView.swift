import God
import Styleguide
import SwiftUI

struct InstagramStoryView: View {
  let question: String
  let color: Color
  let icon: ImageResource
  let gender: String
  let grade: String?
  let schoolName: String?
  let choices: [God.InboxFragment.Choice]

  var body: some View {
    VStack(spacing: 12) {
      HStack(spacing: 8) {
        Image(icon)
          .resizable()
          .frame(width: 40, height: 40)

        Group {
          if let grade {
            Text(verbatim: "\(grade)の\(gender)より")
          } else {
            Text(verbatim: "\(gender)より")
          }
        }
        .font(.system(.callout, design: .rounded, weight: .bold))
        .lineLimit(2)
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity, alignment: .leading)

        if let schoolName {
          Text(schoolName)
            .font(.system(.body, design: .rounded, weight: .bold))
            .foregroundStyle(.godWhite)
            .frame(height: 32)
            .padding(.horizontal, 8)
            .background(Color.godGray)
            .cornerRadius(20)
        }
      }
      VStack(spacing: 8) {
        Text(question)
          .font(.system(.callout, design: .rounded, weight: .bold))
          .foregroundStyle(.godWhite)
          .lineLimit(2)
          .frame(height: 80, alignment: .center)

        ChoiceGrid(
          color: color,
          choices: choices
        )

        Image(ImageResource.godIconWhite)
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(height: 24)
          .foregroundStyle(Color.godWhite)
          .padding(.top, 10)
          .padding(.bottom, 4)

        Text(verbatim: "godapp.jp")
          .font(.system(.callout, design: .rounded, weight: .bold))
          .foregroundStyle(.godWhite)
      }
      .padding(.horizontal, 16)
      .padding(.bottom, 16)
      .background(color)
      .cornerRadius(8)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.black)
  }
}

#Preview {
  InstagramStoryView(
    question: "どんな髪型でも似合うのは？",
    color: Color.godBlue,
    icon: ImageResource.boy,
    gender: "男子",
    grade: "2年生",
    schoolName: nil,
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
            "text": "家 ",
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
    ]
  )
  .environment(\.locale, Locale(identifier: "ja_JP"))
}
