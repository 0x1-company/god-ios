import God
import Styleguide
import SwiftUI

extension God.Gender {
  var text: String {
    switch self {
    case .female:
      return String(localized: "boy", bundle: .module)
    case .male:
      return String(localized: "girl", bundle: .module)
    case .other:
      return String(localized: "someone", bundle: .module)
    }
  }

  var color: Color {
    switch self {
    case .female:
      return Color(0xFFE83392)
    case .male:
      return Color(0xFF00C7FE)
    case .other:
      return Color(0xFF9435EA)
    }
  }
  
  var arrowRight: ImageResource {
    switch self {
    case .female:
      return ImageResource.arrowRightFemale
    case .male:
      return ImageResource.arrowRightMale
    case .other:
      return ImageResource.arrowRightOther
    }
  }
}
