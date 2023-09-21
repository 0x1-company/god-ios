// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension God {
  class CreateTransactionMutation: GraphQLMutation {
    public static let operationName: String = "CreateTransaction"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation CreateTransaction($transactionId: String!) { createTransaction(transactionId: $transactionId) }"#
      ))

    public var transactionId: String

    public init(transactionId: String) {
      self.transactionId = transactionId
    }

    public var __variables: Variables? { ["transactionId": transactionId] }

    public struct Data: God.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { God.Objects.Mutation }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("createTransaction", Bool.self, arguments: ["transactionId": .variable("transactionId")]),
      ] }

      /// Appleの課金情報を登録
      public var createTransaction: Bool { __data["createTransaction"] }
    }
  }

}