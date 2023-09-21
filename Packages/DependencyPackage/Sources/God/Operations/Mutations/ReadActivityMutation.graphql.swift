// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension God {
  class ReadActivityMutation: GraphQLMutation {
    public static let operationName: String = "ReadActivity"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation ReadActivity($activityId: String!) { readActivity(activityId: $activityId) { __typename id isRead } }"#
      ))

    public var activityId: String

    public init(activityId: String) {
      self.activityId = activityId
    }

    public var __variables: Variables? { ["activityId": activityId] }

    public struct Data: God.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { God.Objects.Mutation }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("readActivity", ReadActivity.self, arguments: ["activityId": .variable("activityId")]),
      ] }

      /// Activityを既読にする
      public var readActivity: ReadActivity { __data["readActivity"] }

      /// ReadActivity
      ///
      /// Parent Type: `InboxActivity`
      public struct ReadActivity: God.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { God.Objects.InboxActivity }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", God.ID.self),
          .field("isRead", Bool.self),
        ] }

        /// ID
        public var id: God.ID { __data["id"] }
        /// 既読かどうか
        public var isRead: Bool { __data["isRead"] }
      }
    }
  }

}