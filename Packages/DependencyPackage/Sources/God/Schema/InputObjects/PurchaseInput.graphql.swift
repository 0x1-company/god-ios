// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public extension God {
  struct PurchaseInput: InputObject {
    public private(set) var __data: InputDict

    public init(_ data: InputDict) {
      __data = data
    }

    public init(
      coinAmount: Int,
      storeItemId: String,
      targetUserId: GraphQLNullable<String> = nil
    ) {
      __data = InputDict([
        "coinAmount": coinAmount,
        "storeItemId": storeItemId,
        "targetUserId": targetUserId
      ])
    }

    /// 価格
    public var coinAmount: Int {
      get { __data["coinAmount"] }
      set { __data["coinAmount"] = newValue }
    }

    /// Store Item ID. item IDじゃないので注意
    public var storeItemId: String {
      get { __data["storeItemId"] }
      set { __data["storeItemId"] = newValue }
    }

    /// 対象ユーザ
    public var targetUserId: GraphQLNullable<String> {
      get { __data["targetUserId"] }
      set { __data["targetUserId"] = newValue }
    }
  }

}