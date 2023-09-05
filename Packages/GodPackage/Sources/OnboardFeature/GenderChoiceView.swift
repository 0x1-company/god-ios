import Colors
import God
import SwiftUI

public struct GenderChoiceView: View {
  let gender: God.Gender
  let action: () -> Void
  
  var textGender: String {
    switch gender {
    case .female:
      return "女の子"
    case .male:
      return "男の子"
    case .other:
      return "その他"
    }
  }
  
  var imageNameGender: String {
    switch gender {
    case .female:
      return "girl"
    case .male:
      return "boy"
    case .other:
      return "other"
    }
  }

  public init(
    gender: God.Gender,
    action: @escaping () -> Void
  ) {
    self.gender = gender
    self.action = action
  }

  public var body: some View {
    Button(action: action) {
      VStack(spacing: 4) {
        Image(imageNameGender, bundle: .module)
          .resizable()
          .frame(width: 120, height: 120)
          .cornerRadius(12)

        Text(textGender)
          .foregroundColor(Color.white)
      }
    }
  }
}

struct GenderChoiceViewPreviews: PreviewProvider {
  static var previews: some View {
    GenderChoiceView(
      gender: .male,
      action: {}
    )
    .previewLayout(.sizeThatFits)
    .background(Color.godService)
  }
}
