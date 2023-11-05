// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public extension God {
  struct UpdateUserProfileInput: InputObject {
    public private(set) var __data: InputDict

    public init(_ data: InputDict) {
      __data = data
    }

    public init(
      clubActivityId: GraphQLNullable<String> = nil,
      firstName: GraphQLNullable<String> = nil,
      gender: GraphQLNullable<GraphQLEnum<Gender>> = nil,
      generation: GraphQLNullable<Int> = nil,
      lastName: GraphQLNullable<String> = nil,
      schoolId: GraphQLNullable<String> = nil
    ) {
      __data = InputDict([
        "clubActivityId": clubActivityId,
        "firstName": firstName,
        "gender": gender,
        "generation": generation,
        "lastName": lastName,
        "schoolId": schoolId
      ])
    }

    /// 部活動。nullの場合は更新しない
    public var clubActivityId: GraphQLNullable<String> {
      get { __data["clubActivityId"] }
      set { __data["clubActivityId"] = newValue }
    }

    /// 名前。nullの場合は更新しない
    public var firstName: GraphQLNullable<String> {
      get { __data["firstName"] }
      set { __data["firstName"] = newValue }
    }

    /// 性別。nullの場合は更新しない
    public var gender: GraphQLNullable<GraphQLEnum<Gender>> {
      get { __data["gender"] }
      set { __data["gender"] = newValue }
    }

    /// 学年。nullの場合は更新しない
    public var generation: GraphQLNullable<Int> {
      get { __data["generation"] }
      set { __data["generation"] = newValue }
    }

    /// 苗字。nullの場合は更新しない
    public var lastName: GraphQLNullable<String> {
      get { __data["lastName"] }
      set { __data["lastName"] = newValue }
    }

    /// 学校。nullの場合は更新しない
    public var schoolId: GraphQLNullable<String> {
      get { __data["schoolId"] }
      set { __data["schoolId"] = newValue }
    }
  }

}