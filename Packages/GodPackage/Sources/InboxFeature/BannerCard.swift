import God
import Styleguide
import SwiftUI

struct BannerCard: View {
  let banner: God.BannerCardFragment

  var body: some View {
    Link(destination: URL(string: banner.url)!) {
      VStack(spacing: 0) {
        HStack(spacing: 16) {
          VStack(alignment: .leading, spacing: 4) {
            Text(banner.title)
              .font(.system(.callout, design: .rounded, weight: .bold))

            if let description = banner.description {
              Text(description)
                .foregroundStyle(Color.white.opacity(0.6))
                .font(.system(.footnote, design: .rounded))
            }
          }
          .multilineTextAlignment(.leading)
          .frame(maxWidth: .infinity, alignment: .leading)

          Image(systemName: "chevron.right")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .foregroundStyle(.white)
        .background(Color.godService)
      }
    }
  }
}

#Preview {
  BannerCard(
    banner: God.BannerCardFragment(
      _dataDict: DataDict(
        data: [
          "id": "1",
          "title": "【スタバギフトプレゼント】ヒアリングご協力の依頼",
          "description": "Godアプリをさらに楽しく改善するために、オンラインでの30分間のヒアリングにご協力していただける方を募集しています。",
          "url": "https://godapp.jp",
          "startAt": "",
          "endAt": "",
        ],
        fulfilledFragments: []
      )
    )
  )
}
