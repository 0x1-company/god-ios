// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension God {
  class CreateContactsMutation: GraphQLMutation {
    public static let operationName: String = "CreateContacts"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation CreateContacts($contacts: [ContactInput!]!) { createContacts(contacts: $contacts) }"#
      ))

    public var contacts: [ContactInput]

    public init(contacts: [ContactInput]) {
      self.contacts = contacts
    }

    public var __variables: Variables? { ["contacts": contacts] }

    public struct Data: God.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { God.Objects.Mutation }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("createContacts", Bool.self, arguments: ["contacts": .variable("contacts")]),
      ] }

      /// 連絡先を保存する
      public var createContacts: Bool { __data["createContacts"] }
    }
  }

}