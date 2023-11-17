import God
import NameImage
import Styleguide
import SwiftUI

public struct ReceivedSticker: View {
  let questionText: String
  let gender: God.Gender
  let grade: String?
  let avatarImageData: Data?
  let firstName: String

  public init(
    questionText: String,
    gender: God.Gender,
    grade: String?,
    avatarImageData: Data?,
    firstName: String
  ) {
    self.questionText = questionText
    self.gender = gender
    self.grade = grade
    self.avatarImageData = avatarImageData
    self.firstName = firstName
  }

  public var body: some View {
    VStack(spacing: 0) {
      Group {
        if let grade {
          Text("multi-from-\(gender.text)-in-\(grade)", bundle: .module)
        } else {
          Text("From a \(gender.text)", bundle: .module)
        }
      }
      .font(.system(.title3, design: .rounded, weight: .bold))
      .padding(.horizontal, 12)
      .padding(.top, 46)
      .padding(.bottom, 12)
      .frame(maxWidth: .infinity)
      .foregroundStyle(Color.white)
      .background(gender.color)

      Text(questionText)
        .font(.system(.title3, design: .rounded, weight: .bold))
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
              .foregroundStyle(gender.color)
              .font(.system(size: 42, weight: .bold))
          }
          .overlay(alignment: .bottomTrailing) {
            Image(systemName: "questionmark")
              .foregroundStyle(gender.color)
              .frame(width: 24, height: 24)
              .font(.system(size: 14, weight: .bold))
              .background(Color.white)
              .clipShape(Circle())
              .overlay(
                RoundedRectangle(cornerRadius: 24 / 2)
                  .stroke(gender.color, lineWidth: 2)
              )
          }

        Image(gender.arrowRight)
          .offset(y: -4)

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
      }
      .offset(y: -32)
    }
  }
}

#Preview {
  VStack(spacing: 0) {
    ReceivedSticker(
      questionText: "Your ideal study buddy",
      gender: God.Gender.female,
      grade: "11th grade",
      avatarImageData: nil,
      firstName: "TT"
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
