import Colors
import God
import SwiftUI

public struct GenderChoiceView: View {
  let gender: God.Gender
  let action: () -> Void

  var textGender: LocalizedStringKey {
    switch gender {
    case .female:
      return "Girl"
    case .male:
      return "Boy"
    case .other:
      return "Non-binary"
    }
  }

  var imageNameGender: ImageResource {
    switch gender {
    case .female:
      return ImageResource.girl
    case .male:
      return ImageResource.boy
    case .other:
      return ImageResource.other
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
        Image(imageNameGender)
          .resizable()
          .frame(width: 120, height: 120)
          .cornerRadius(12)

        Text(textGender, bundle: .module)
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
