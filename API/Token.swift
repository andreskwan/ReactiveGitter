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

import JSONCodable

public struct Token {
  public let accessToken: String   // The token that can be used to access the Gitter API.
  public let tokenType: String     // The type of token received. At this time, this field will always have the value Bearer.
  public let expiresIn: String?    // The remaining lifetime on the access token.

  public init(accessToken: String, tokenType: String, expiresIn: String? = nil) {
    self.accessToken = accessToken
    self.tokenType = tokenType
    self.expiresIn = expiresIn
  }
}

extension Token {

  public static var generator: Resource {
    return Resource(path: "token")
  }
  
  public struct Resource {

    public let path: String

    public func generate(clientID: String, clientSecret: String, authorizationCode: String, redirectURI: String) -> Request<AnyObject, Token, Error> {
      let parameters = [
        "client_id": clientID,
        "client_secret": clientSecret,
        "code": authorizationCode,
        "redirect_uri": redirectURI,
        "grant_type": "authorization_code"
        ] as [String: AnyObject]
      return Request(path: path, method: .POST, parameters: parameters, parser: Token.parseJSON)
    }
  }
}

extension Token: JSONDecodable {

  public init(object: JSONObject) throws {
    let decoder = JSONDecoder(object: object)
    accessToken = try decoder.decode("access_token")
    expiresIn = try decoder.decode("expires_in")
    tokenType = try decoder.decode("token_type")
  }
}
