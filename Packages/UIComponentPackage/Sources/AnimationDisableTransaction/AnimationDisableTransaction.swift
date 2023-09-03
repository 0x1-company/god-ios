import SwiftUI

public extension SwiftUI.Transaction {
  static let animationDisable: Transaction = {
    var transaction = SwiftUI.Transaction()
    transaction.disablesAnimations = true
    return transaction
  }()
}
