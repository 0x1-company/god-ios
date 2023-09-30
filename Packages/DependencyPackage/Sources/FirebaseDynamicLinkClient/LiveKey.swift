import Dependencies
import FirebaseDynamicLinks

extension FirebaseDynamicLinkClient: DependencyKey {
  public static let liveValue = Self(
  )
}

func hoge() {
//  let link = URL(string: "https://mygame.example.com/?invitedby=\(uid)")
//  let referralLink = DynamicLinkComponents(link: link!, domain: "example.page.link")
//
//  referralLink.iOSParameters = DynamicLinkIOSParameters(bundleID: "com.example.ios")
//  referralLink.iOSParameters?.minimumAppVersion = "1.0.1"
//  referralLink.iOSParameters?.appStoreID = "123456789"
  let link = URL(string: "")!
  let referralLink = DynamicLinkComponents(link: link, domainURIPrefix: "example.page.link")
  referralLink?.iOSParameters = DynamicLinkIOSParameters(bundleID: "")
}
