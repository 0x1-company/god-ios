import XCTest
import StringHelpers

final class StringHelpersTests: XCTestCase {
  func testTransformToHiragana_成功() {
    let katakana = "トモキ"
    let hiragana = try! transformToHiragana(for: katakana)
    XCTAssertEqual(hiragana, "ともき")
  }
  
  func testTransformToHiragana_カタカナ以外がインプットされたとき() {
    let value = "Tomoki"
    XCTAssertThrowsError(try transformToHiragana(for: value), "カタカナ以外がインプットされたとき")
  }
  
  func testValidateHiragana() {
    XCTAssertTrue(validateHiragana(for: "ともき"))
    XCTAssertFalse(validateHiragana(for: "トモキ"))
    XCTAssertFalse(validateHiragana(for: "Tomoki"))
  }
  
  func testValidateKatakana() {
    XCTAssertTrue(validateKatakana(for: "トモキ"))
    XCTAssertFalse(validateKatakana(for: "ともき"))
    XCTAssertFalse(validateKatakana(for: "Tomoki"))
  }
}
