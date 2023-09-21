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
      case "FirebaseRegistrationToken": return God.Objects.FirebaseRegistrationToken
      case "Friend": return God.Objects.Friend
      case "User": return God.Objects.User
      case "UserBlock": return God.Objects.UserBlock
      case "CompletePollResponse": return God.Objects.CompletePollResponse
      case "Vote": return God.Objects.Vote
      case "UserHide": return God.Objects.UserHide
      case "Query": return God.Objects.Query
      case "School": return God.Objects.School
      case "LocalizableString": return God.Objects.LocalizableString
      case "UserConnection": return God.Objects.UserConnection
      case "PageInfo": return God.Objects.PageInfo
      case "UserEdge": return God.Objects.UserEdge
      case "Wallet": return God.Objects.Wallet
      case "Store": return God.Objects.Store
      case "StoreItem": return God.Objects.StoreItem
      case "InboxActivityConnection": return God.Objects.InboxActivityConnection
      case "InboxActivityEdge": return God.Objects.InboxActivityEdge
      case "InboxActivity": return God.Objects.InboxActivity
      case "Question": return God.Objects.Question
      case "ActivityConnection": return God.Objects.ActivityConnection
      case "ActivityEdge": return God.Objects.ActivityEdge
      case "Activity": return God.Objects.Activity
      case "CurrentPoll": return God.Objects.CurrentPoll
      case "CoolDown": return God.Objects.CoolDown
      case "Poll": return God.Objects.Poll
      case "PollQuestion": return God.Objects.PollQuestion
      case "ChoiceGroup": return God.Objects.ChoiceGroup
      case "Signature": return God.Objects.Signature
      case "Choice": return God.Objects.Choice
      case "Subscription": return God.Objects.Subscription
      case "FriendConnection": return God.Objects.FriendConnection
      case "FriendEdge": return God.Objects.FriendEdge
      default: return nil
      }
    }
  }

  enum Objects {}
  enum Interfaces {}
  enum Unions {}

}