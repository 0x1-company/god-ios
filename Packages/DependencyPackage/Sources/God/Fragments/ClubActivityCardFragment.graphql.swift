// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension God {
  struct ClubActivityCardFragment: God.SelectionSet, Fragment {
    public static var fragmentDefinition: StaticString {
      #"fragment ClubActivityCardFragment on ClubActivity { __typename id name position }"#
    }

    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { God.Objects.ClubActivity }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("id", God.ID.self),
      .field("name", String.self),
      .field("position", Int.self),
    ] }

    public var id: God.ID { __data["id"] }
    public var name: String { __data["name"] }
    public var position: Int { __data["position"] }
  }

}