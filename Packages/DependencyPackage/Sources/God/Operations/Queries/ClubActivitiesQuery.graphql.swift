// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension God {
  class ClubActivitiesQuery: GraphQLQuery {
    public static let operationName: String = "ClubActivities"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query ClubActivities { clubActivities { __typename ...ClubActivityCardFragment } }"#,
        fragments: [ClubActivityCardFragment.self]
      ))

    public init() {}

    public struct Data: God.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { God.Objects.Query }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("clubActivities", [ClubActivity].self),
      ] }

      /// 部活動の一覧を取得する
      public var clubActivities: [ClubActivity] { __data["clubActivities"] }

      /// ClubActivity
      ///
      /// Parent Type: `ClubActivity`
      public struct ClubActivity: God.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { God.Objects.ClubActivity }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .fragment(ClubActivityCardFragment.self),
        ] }

        public var id: God.ID { __data["id"] }
        public var name: String { __data["name"] }
        public var position: Int { __data["position"] }

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public var clubActivityCardFragment: ClubActivityCardFragment { _toFragment() }
        }
      }
    }
  }

}