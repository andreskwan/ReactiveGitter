//
//  TokenService.swift
//  ReactiveGitter
//
//  Created by Srdan Rasic on 11/05/16.
//  Copyright © 2016 Srdan Rasic. All rights reserved.
//

import ReactiveKit
import API

public class TokenService {

  public enum AuthorizationResponse {
    case Authorized(String)
    case Unauthorized(String)
  }

  private var _token = Property<Token?>(nil)
  public var token: Stream<Token?> {
    return _token.toStream()
  }

  public init() {
    if let accessToken = NSUserDefaults.standardUserDefaults().objectForKey("token") as? String {
      _token.value = Token(accessToken: accessToken, tokenType: "Bearer")
    }
  }

  public func updateToken(token: Token?) {
    // TODO: Use Keychain instead
    NSUserDefaults.standardUserDefaults().setObject(token?.accessToken, forKey: "token")
    NSUserDefaults.standardUserDefaults().synchronize()
    _token.value = token
  }

  public class AuthorizationCodeParser {
    
    private let _parsedCode = PushStream<AuthorizationResponse>()
    public var parsedCode: Stream<AuthorizationResponse> {
      return _parsedCode.toStream()
    }

    public init() {}

    public func parseAndHandleToken(url: NSURL) -> Bool {
      let components = NSURLComponents(URL: url, resolvingAgainstBaseURL: false)!

      guard let host = components.host where host == "token" else {
        return false
      }

      if let keyValue = components.queryItems?.filter({ $0.name == "code" }).first, code = keyValue.value  {
        _parsedCode.next(.Authorized(code))
        return true
      } else {
        _parsedCode.next(.Unauthorized("Token request code not received."))
        return false
      }
    }
  }
}
