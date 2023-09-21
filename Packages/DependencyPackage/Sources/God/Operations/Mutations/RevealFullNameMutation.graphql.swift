// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension God {
  class RevealFullNameMutation: GraphQLMutation {
    public static let operationName: String = "RevealFullName"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation RevealFullName($input: RevealFullNameInput!) { revealFullName(input: $input) { __typename ja } }"#
      ))

    public var input: RevealFullNameInput

    public init(input: RevealFullNameInput) {
      self.input = input
    }

    public var __variables: Variables? { ["input": input] }

    public struct Data: God.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { God.Objects.Mutation }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("revealFullName", RevealFullName?.self, arguments: ["input": .variable("input")]),
      ] }

      public var revealFullName: RevealFullName? { __data["revealFullName"] }

      /// RevealFullName
      ///
      /// Parent Type: `LocalizableString`
      public struct RevealFullName: God.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { God.Objects.LocalizableString }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("ja", String.self),
        ] }

        /// 日本語
        public var ja: String { __data["ja"] }
      }
    }
  }

}