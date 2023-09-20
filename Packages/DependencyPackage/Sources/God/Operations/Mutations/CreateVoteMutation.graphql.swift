// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension God {
  class CreateVoteMutation: GraphQLMutation {
    public static let operationName: String = "CreateVote"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation CreateVote($input: CreateVoteInput!) { createVote(input: $input) { __typename id } }"#
      ))

    public var input: CreateVoteInput

    public init(input: CreateVoteInput) {
      self.input = input
    }

    public var __variables: Variables? { ["input": input] }

    public struct Data: God.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { God.Objects.Mutation }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("createVote", CreateVote.self, arguments: ["input": .variable("input")]),
      ] }

      /// 投票する
      public var createVote: CreateVote { __data["createVote"] }

      /// CreateVote
      ///
      /// Parent Type: `Vote`
      public struct CreateVote: God.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { God.Objects.Vote }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", God.ID.self),
        ] }

        public var id: God.ID { __data["id"] }
      }
    }
  }

}