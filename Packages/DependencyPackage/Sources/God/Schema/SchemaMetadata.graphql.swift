// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public protocol God_SelectionSet: ApolloAPI.SelectionSet & ApolloAPI.RootSelectionSet
where Schema == God.SchemaMetadata {}

public protocol God_InlineFragment: ApolloAPI.SelectionSet & ApolloAPI.InlineFragment
where Schema == God.SchemaMetadata {}

public protocol God_MutableSelectionSet: ApolloAPI.MutableRootSelectionSet
where Schema == God.SchemaMetadata {}

public protocol God_MutableInlineFragment: ApolloAPI.MutableSelectionSet & ApolloAPI.InlineFragment
where Schema == God.SchemaMetadata {}

public extension God {
  typealias ID = String

  typealias SelectionSet = God_SelectionSet

  typealias InlineFragment = God_InlineFragment

  typealias MutableSelectionSet = God_MutableSelectionSet

  typealias MutableInlineFragment = God_MutableInlineFragment

  enum SchemaMetadata: ApolloAPI.SchemaMetadata {
    public static let configuration: ApolloAPI.SchemaConfiguration.Type = SchemaConfiguration.self

    public static func objectType(forTypename typename: String) -> Object? {
      switch typename {
      case "Mutation": return God.Objects.Mutation
      case "User": return God.Objects.User
      case "Query": return God.Objects.Query
      case "School": return God.Objects.School
      default: return nil
      }
    }
  }

  enum Objects {}
  enum Interfaces {}
  enum Unions {}

}