import God
import SwiftUI
import RoundedCorner
import ProfileImage

struct ReceivedActivityList: View {
  let profileImageUrl: String
  let name: String
  let displayName: String
  let grade: String?
  let gender: GraphQLEnum<God.Gender>
  
  var starIcon: ImageResource {
    if gender == God.Gender.female {
      return ImageResource.boy
    }
    return ImageResource.girl
  }
  
  var differentGender: String {
    if gender == God.Gender.female {
      return String(localized: "boy", bundle: .module)
    }
    return String(localized: "girl", bundle: .module)
  }
  
  var fromGenderGrade: String {
    if let grade {
      return String(localized: "From a \(differentGender) in \(grade)", bundle: .module)
    }
    return String(localized: "From a \(differentGender)", bundle: .module)
  }

  var body: some View {
    VStack(spacing: 0) {
      HStack(alignment: .top, spacing: 8) {
        ProfileImage(
          urlString: profileImageUrl,
          name: name,
          size: 40
        )
        .clipShape(Circle())
        
        VStack(alignment: .leading, spacing: 4) {
          HStack(spacing: 4) {
            Text(displayName)
              .bold()
            Text("received", bundle: .module)
              .font(.system(.footnote, design: .rounded))
          }
          Text("Like to go play with you", bundle: .module)

          HStack(spacing: 8) {
            Image(starIcon)
              .resizable()
              .aspectRatio(contentMode: .fit)
              .clipped()
              .frame(width: 14, height: 14)
            
            Text(fromGenderGrade)
              .foregroundStyle(Color.secondary)
          }
        }
        .font(.system(.callout, design: .rounded))
        .frame(maxWidth: .infinity, alignment: .leading)
      }
      .padding(.vertical, 10)
      .padding(.horizontal, 12)
      .background(Color.white)
      .cornerRadius(12)
      
      HStack(alignment: .top, spacing: 8) {
        ProfileImage(
          urlString: profileImageUrl,
          name: name,
          size: 28
        )
        .clipShape(Circle())
        
        VStack(alignment: .leading, spacing: 4) {
          HStack(spacing: 4) {
            Text(displayName)
              .bold()
            Text("received", bundle: .module)
              .font(.system(.footnote, design: .rounded))
          }
          Text("Like your fashion", bundle: .module)
        }
        .font(.system(.callout, design: .rounded))
        .frame(maxWidth: .infinity, alignment: .leading)
      }
      .padding(.top, 4)
      .padding(.bottom, 10)
      .padding(.horizontal, 12)
      .background(Color.white)
      .cornerRadius(12, corners: [.bottomLeft, .bottomRight])
      .padding(.horizontal, 22)
      .opacity(0.8)
      
      HStack(alignment: .top, spacing: 8) {
        Color.gray
          .frame(width: 20, height: 20)
          .clipShape(Circle())
        
        VStack(alignment: .leading, spacing: 8) {
          Color.gray
            .frame(width: 110, height: 7)
            .clipShape(Capsule())
          
          Color.gray
            .frame(width: 52, height: 7)
            .clipShape(Capsule())
        }
        .font(.system(.callout, design: .rounded))
        .frame(maxWidth: .infinity, alignment: .leading)
      }
      .padding(.top, 4)
      .padding(.bottom, 14)
      .padding(.horizontal, 12)
      .background(Color.white)
      .cornerRadius(12, corners: [.bottomLeft, .bottomRight])
      .padding(.horizontal, 44)
      .opacity(0.6)
    }
  }
}
