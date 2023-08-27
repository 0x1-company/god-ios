import Apollo
import ApolloAPI
import FirebaseAuth
import Foundation
import os

private let logger = Logger(subsystem: "jp.godapp", category: "FirebaseTokenInterceptor")

class FirebaseTokenInterceptor: ApolloInterceptor {
  var id: String = UUID().uuidString

  func interceptAsync<Operation: GraphQLOperation>(
    chain: RequestChain,
    request: HTTPRequest<Operation>,
    response: HTTPResponse<Operation>?,
    completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void
  ) {
    guard let currentUser = Auth.auth().currentUser else {
      logger.warning("not found firebase current user")
      addTokenAndProceed(
        "",
        to: request,
        chain: chain,
        response: response,
        completion: completion
      )
      return
    }
    currentUser.getIDToken(completion: { [weak self] token, error in
      if let error {
        logger.error("\(error.localizedDescription)")
      }
      self?.addTokenAndProceed(
        token ?? "",
        to: request,
        chain: chain,
        response: response,
        completion: completion
      )
    })
  }

  private func addTokenAndProceed<Operation: GraphQLOperation>(
    _ token: String,
    to request: HTTPRequest<Operation>,
    chain: RequestChain,
    response: HTTPResponse<Operation>?,
    completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void
  ) {
    request.addHeader(name: "Authorization", value: "Bearer \(token)")
    chain.proceedAsync(
      request: request,
      response: response,
      interceptor: self,
      completion: completion
    )
  }
}
