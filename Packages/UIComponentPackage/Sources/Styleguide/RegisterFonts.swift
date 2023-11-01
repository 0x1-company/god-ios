import UIKit

@discardableResult
public func registerFonts() -> Bool {
  [
    UIFont.registerFont(bundle: .module, fontName: "MPLUSRounded1c-Black", fontExtension: "ttf"),
    UIFont.registerFont(bundle: .module, fontName: "MPLUSRounded1c-Bold", fontExtension: "ttf"),
    UIFont.registerFont(bundle: .module, fontName: "MPLUSRounded1c-Regular", fontExtension: "ttf"),
  ]
  .allSatisfy { $0 }
}

extension UIFont {
  static func registerFont(bundle: Bundle, fontName: String, fontExtension: String) -> Bool {
    guard let fontURL = bundle.url(forResource: fontName, withExtension: fontExtension) else {
      fatalError("Couldn't find font \(fontName)")
    }
    guard let fontDataProvider = CGDataProvider(url: fontURL as CFURL) else {
      fatalError("Couldn't load data from the font \(fontName)")
    }
    guard let font = CGFont(fontDataProvider) else {
      fatalError("Couldn't create font from data")
    }

    var error: Unmanaged<CFError>?
    let success = CTFontManagerRegisterGraphicsFont(font, &error)
    guard success else {
      print(
        """
        Error registering font: \(fontName). Maybe it was already registered.\
        \(error.map { " \($0.takeUnretainedValue().localizedDescription)" } ?? "")
        """
      )
      return true
    }

    return true
  }
}
