import SwiftUI
import RoundedCorner

struct ReceivedActivityList: View {
  var body: some View {
    VStack(spacing: 0) {
      HStack(alignment: .top, spacing: 8) {
        Color.red
          .frame(width: 40, height: 40)
          .clipShape(Circle())
        
        VStack(alignment: .leading, spacing: 4) {
          HStack(spacing: 4) {
            Text("tomokisun")
              .bold()
            Text("received", bundle: .module)
              .font(.system(.footnote, design: .rounded))
          }
          Text("Like to go play with you", bundle: .module)

          HStack(spacing: 8) {
            Image(.boy)
              .resizable()
              .aspectRatio(contentMode: .fit)
              .clipped()
              .frame(width: 14, height: 14)
            
            Text("From a boy in 9th grade", bundle: .module)
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
        Color.red
          .frame(width: 28, height: 28)
          .clipShape(Circle())
        
        VStack(alignment: .leading, spacing: 4) {
          HStack(spacing: 4) {
            Text("tomokisun")
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

#Preview {
  ReceivedActivityList()
}
