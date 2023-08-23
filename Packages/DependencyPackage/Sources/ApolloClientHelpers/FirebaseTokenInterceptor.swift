import Apollo
import ApolloAPI
import FirebaseAuth
import Foundation
import os

let logger = Logger(subsystem: "jp.godapp", category: #file)

class FirebaseTokenInterceptor: ApolloInterceptor {
  var id: String = UUID().uuidString

  func interceptAsync<Operation: GraphQLOperation>(
    chain: RequestChain,
    request: HTTPRequest<Operation>,
    response: HTTPResponse<Operation>?,
    completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void
  ) {
    Auth.auth().currentUser?.getIDToken(completion: { [weak self] token, error in
      if let error {
        logger.error("\(error.localizedDescription)")
      }
      if let token {
        logger.info("\(token)")
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
