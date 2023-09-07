// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension God {
  struct NextPaginationFragment: God.SelectionSet, Fragment {
    public static var fragmentDefinition: StaticString {
      #"fragment NextPaginationFragment on PageInfo { __typename hasNextPage endCursor }"#
    }

    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { God.Objects.PageInfo }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("hasNextPage", Bool.self),
      .field("endCursor", String?.self),
    ] }

    /// 次のページがあるかどうか
    public var hasNextPage: Bool { __data["hasNextPage"] }
    /// 最後のedgeのカーソル
    public var endCursor: String? { __data["endCursor"] }
  }

}