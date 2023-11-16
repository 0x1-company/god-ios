import Styleguide
import SwiftUI

#Preview {
  VStack(spacing: 0) {
    ChoiceListSticker(
      questionText: "かけてあるバックの持ち手が片方だけ外れてたら、そっと治す"
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
}
