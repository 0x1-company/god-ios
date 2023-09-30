import Dependencies
import FirebaseDynamicLinks

extension FirebaseDynamicLinkClient: DependencyKey {
  public static let liveValue = Self(
    shouldHandleDynamicLink: { url in
      DynamicLinks.dynamicLinks().shouldHandleDynamicLink(fromCustomSchemeURL: url)
    },
    dynamicLink: { url in
      DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: url)
    }
  )
}
