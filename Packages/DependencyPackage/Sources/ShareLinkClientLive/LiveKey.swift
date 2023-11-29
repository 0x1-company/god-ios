import Dependencies
import Foundation
import God
import ShareLinkClient

extension String: Error {}

extension ShareLinkClient {
  static func live(fetch: @escaping () async throws -> God.ShareLinkClientQuery.Data) -> Self {
    return ShareLinkClient(
      generateSharedText: { path, source, medium in
        let data = try await fetch()
        guard let username = data.currentUser.username else {
          throw "username could not be retrieved."
        }
        
        let link = generateLink(path: path, username: username, source: source, medium: medium)
        let invitationCode = data.invitationCode.code
        return generateText(link: link, invitationCode: invitationCode)
      }
    )
  }
}

func generateLink(
  path: ShareLinkClient.GodAppJpPath,
  username: String,
  source: ShareLinkClient.UtmSource? = nil,
  medium: ShareLinkClient.UtmMedium? = nil
) -> String {
  var components = URLComponents(string: "https://www.godapp.jp")!
  components.path = "/\(path.rawValue)/\(username)"
  var queryItems: [URLQueryItem] = []
  if let source {
    queryItems.append(URLQueryItem(name: "utm_source", value: source.rawValue))
  }
  if let medium {
    queryItems.append(URLQueryItem(name: "utm_medium", value: medium.rawValue))
  }
  if !queryItems.isEmpty {
    components.queryItems = queryItems
  }
  return components.url!.absoluteString
}

func generateText(
  link: String,
  invitationCode: String
) -> String {
  return String(
    localized: "God is an interesting app, try it!\n\nInvitation Code: \(invitationCode)\n\n\(link)",
    bundle: .module
  )
}
