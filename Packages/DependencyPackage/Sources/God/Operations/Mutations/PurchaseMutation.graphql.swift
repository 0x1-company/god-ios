// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension God {
  class PurchaseMutation: GraphQLMutation {
    public static let operationName: String = "Purchase"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation Purchase($input: PurchaseInput!) { purchase(input: $input) }"#
      ))

    public var input: PurchaseInput

    public init(input: PurchaseInput) {
      self.input = input
    }

    public var __variables: Variables? { ["input": input] }

    public struct Data: God.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { God.Objects.Mutation }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("purchase", Bool.self, arguments: ["input": .variable("input")]),
      ] }

      public var purchase: Bool { __data["purchase"] }
    }
  }

}