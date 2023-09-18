// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension God {
  struct FriendRequestCardFragment: God.SelectionSet, Fragment {
    public static var fragmentDefinition: StaticString {
      #"fragment FriendRequestCardFragment on Friend { __typename id }"#
    }

    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { God.Objects.Friend }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("id", God.ID.self),
    ] }

    public var id: God.ID { __data["id"] }
  }

}