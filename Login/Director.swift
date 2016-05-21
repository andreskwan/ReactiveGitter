//
//  Director.swift
//  ReactiveGitter
//
//  Created by Srdan Rasic on 11/05/16.
//  Copyright © 2016 Srdan Rasic. All rights reserved.
//

import ReactiveKit
import API

// TODO: Put in a config file.
private let key = "31625d251b64ec0f01b19577c150f8bcb8c5f6a3"
private let secret = "e629e37430a3a37905f642972caf3e6dce28d819"
private let uri = "reactive-gitter://token"

class Director {

  let token: Stream<Token>
  let urlToOpen: Stream<NSURL>

  let error: Stream<String>

  init(loginAction: Stream<Void>, authorizationCode: Stream<TokenService.AuthorizationResponse>) {

    let tokenRequest = authorizationCode
      .tryMap { code -> Result<String, Error> in
        switch code {
        case .Authorized(let code):
          return .Success(code)
        case .Unauthorized(let error):
          return .Failure(Error(error: error))
        }
      }
      .flatMapLatest { code in
        Token.generator.generate(key, clientSecret: secret, authorizationCode: code, redirectURI: uri).toOperationIn(API.authenticationAPI)
      }

    (token, error) = tokenRequest.toStream { $0.error }
    urlToOpen = loginAction.map { API.AuthenticationAPI.authorizationURL(key, redirectURI: uri) }
  }
}
