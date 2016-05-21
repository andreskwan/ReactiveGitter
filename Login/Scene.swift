//
//  Scene.swift
//  ReactiveGitter
//
//  Created by Srdan Rasic on 11/05/16.
//  Copyright © 2016 Srdan Rasic. All rights reserved.
//

import ReactiveKit
import Common
import API

public class Scene {

  let context: Context
  let authorizationCode: Stream<TokenService.AuthorizationResponse>
  let saveToken: Token? -> Void

  public init(context: Context, authorizationCode: Stream<TokenService.AuthorizationResponse>, saveToken: Token? -> Void) {
    self.authorizationCode = authorizationCode
    self.saveToken = saveToken
    self.context = context
  }

  public func presentInContext() {
    context.present(stage())
  }

  func stage() -> UIViewController {
    return Stage { stage in
      let d = Director(loginAction: stage.loginButton.rTap, authorizationCode: self.authorizationCode)
      d.token.observeNext(self.saveToken).disposeIn(stage.rBag)
      d.urlToOpen.observeNext { UIApplication.sharedApplication().openURL($0) }.disposeIn(stage.rBag)
      return d
    }
  }
}
