//
//  The MIT License (MIT)
//
//  Copyright (c) 2015 Srdan Rasic (@srdanrasic)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation
import Alamofire

private let GitterAPIBaseURL = "https://api.gitter.im/v1"
private let GitterAPIBaseStreamURL = "https://stream.gitter.im/v1"
private let GitterAuthorizationBaseURL = "https://gitter.im/login/oauth/authorize"
private let GitterAuthenticationAPIBaseURL = "https://gitter.im/login/oauth"

public class API: APIBase {

  public class AuthenticationAPI: APIBase {

    public init() {
      super.init(baseURL: GitterAuthenticationAPIBaseURL)
    }

    public static func authorizationURL(clientID: String, redirectURI: String) -> NSURL {
      return NSURL(string: "\(GitterAuthorizationBaseURL)?client_id=\(clientID)&response_type=code&redirect_uri=\(redirectURI)")!
    }
  }

  public class StreamingAPI: API {

    public override init(token: Token) {
      super.init(baseURL: GitterAPIBaseStreamURL, token: token)
    }
  }

  private let token: Token

  public var streamingAPI: StreamingAPI {
    return StreamingAPI(token: token)
  }

  public static var authenticationAPI: AuthenticationAPI {
    return AuthenticationAPI()
  }

  private init(baseURL: String, token: Token) {
    self.token = token
    super.init(baseURL: baseURL)
  }

  public init(token: Token) {
    self.token = token
    super.init(baseURL: GitterAPIBaseURL)
  }

  override func prepareRequest<T, U, E: APIErrorType>(request: Request<T, U, E>) -> Request<T, U, E> {
    var request = super.prepareRequest(request)
    var headers = request.headers ?? [:]
    headers["Authorization"] = "Bearer \(token.accessToken)"
    request.headers = headers
    return request
  }
}

public class APIBase {

  public let baseURL: String
  public let manager: Manager

  public init(baseURL: String, manager: Manager = Manager.sharedInstance) {
    self.baseURL = baseURL
    self.manager = manager
  }

  func prepareRequest<T, U, E: APIErrorType>(request: Request<T, U, E>) -> Request<T, U, E> {
    return request
  }

  func toAlamofireRequest<T, U, E: APIErrorType>(request: Request<T, U, E>) -> Alamofire.Request {
    let r = prepareRequest(request)
    let url = baseURL.appendPathComponent(r.path)
    return manager.request(r.method, url, parameters: r.parameters, encoding: r.encoding, headers: r.headers)
  }
}
