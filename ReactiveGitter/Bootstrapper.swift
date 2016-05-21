//
//  Bootstrapper.swift
//  ReactiveGitter
//
//  Created by Srdan Rasic on 11/05/16.
//  Copyright © 2016 Srdan Rasic. All rights reserved.
//

import UIKit
import ReactiveKit
import Common
import Login
import Home
import API

struct Bootstrapper {

  let context: WindowContext
  let token: Stream<Token?>
  let authorizationCode: Stream<TokenService.AuthorizationResponse>
  let saveToken: Token? -> Void

  let disposeBag = DisposeBag()

  func bootstrap() {
    token.observeIn(ImmediateOnMainExecutionContext).observeNext { token in
      if let token = token {
        let context = NavigationControllerContext(parent: self.context)
        let scene = Home.Scene(context: context, api: API(token: token))
        scene.wantsLogout.observeNext { self.saveToken(nil) }.disposeIn(self.disposeBag)
        scene.presentInContext()
      } else {
        Login.Scene(context: self.context, authorizationCode: self.authorizationCode, saveToken: self.saveToken).presentInContext()
      }
    }.disposeIn(disposeBag)
  }
}
