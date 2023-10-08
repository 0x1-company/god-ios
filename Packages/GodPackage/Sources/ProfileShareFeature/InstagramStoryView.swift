import Colors
import NameImage
import ProfileImage
import SwiftUI

struct InstagramStoryView: View {
  let profileImageData: Data?
  let lastName: String
  let firstName: String
  let displayName: String
  let username: String?
  let schoolImageData: Data?
  let schoolName: String?

  var body: some View {
    VStack(spacing: 0) {
      VStack(spacing: 24) {
        Group {
          if let profileImageData, let image = UIImage(data: profileImageData) {
            Image(uiImage: image)
              .resizable()
              .aspectRatio(contentMode: .fill)
              .frame(width: 86, height: 86)
              .clipShape(Circle())
          } else {
            NameImage(name: firstName, size: 86)
          }
        }
        .overlay(
          RoundedRectangle(cornerRadius: 86 / 2)
            .stroke(Color.godService, lineWidth: 3)
        )

        Text(verbatim: "@\(username ?? "")")
          .font(.body)
          .foregroundStyle(Color.godTextSecondaryLight)

        VStack(spacing: 8) {
          Text("Add me on", bundle: .module)
            .font(.title2)
            .fontWeight(.heavy)
            .foregroundStyle(Color.godWhite)
          Image("god-icon-white", bundle: .module)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: 24)
            .foregroundStyle(Color.godWhite)
            .padding(.bottom, 4)
          Text(verbatim: "godapp.jp")
            .font(.callout)
            .bold()
            .foregroundColor(.godWhite)
        }
        .padding(.bottom, 8)

        HStack(spacing: 8) {
          Group {
            if let schoolImageData, let image = UIImage(data: schoolImageData) {
              Image(uiImage: image)
                .resizable()
                .frame(width: 36, height: 36)
                .scaledToFit()
                .clipped()
            } else {
              Image(ImageResource.school)
                .resizable()
                .frame(width: 36, height: 36)
                .scaledToFit()
                .clipped()
            }
          }

          VStack(spacing: 0) {
            Text(schoolName ?? "")
          }
          .foregroundStyle(Color.godWhite)
          .font(.footnote)
          .lineLimit(2)
          .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .frame(height: 48)
        .background(Color(red: 30 / 255, green: 30 / 255, blue: 30 / 255))
      }
      .padding(.top, 32)
      .background(Color(red: 35 / 255, green: 35 / 255, blue: 35 / 255))
      .cornerRadius(16)
      .clipShape(RoundedRectangle(cornerRadius: 8))
      .frame(minWidth: 280)
    }
    .background(Color.clear)
  }
}

#Preview {
  InstagramStoryView(
    profileImageData: nil,
    lastName: "つきやま",
    firstName: "ともき",
    displayName: "つきやま ともき",
    username: "tomokisun",
    schoolImageData: nil,
    schoolName: "東京都立国際高等学校"
  )
}
