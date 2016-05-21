//
//  AppDelegate.swift
//  ReactiveGitter
//
//  Created by Srdan Rasic on 08/05/16.
//  Copyright © 2016 Srdan Rasic. All rights reserved.
//

import UIKit
import Common
import Login

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  var bootstrapper: Bootstrapper!
  let authorizationCodeParser = TokenService.AuthorizationCodeParser()


  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

    applyTheme()

    window = UIWindow(frame: UIScreen.mainScreen().bounds)
    window?.makeKeyAndVisible()

    let tokenService = TokenService()

    bootstrapper = Bootstrapper(
      context: WindowContext(window: window!),
      token: tokenService.token,
      authorizationCode: authorizationCodeParser.parsedCode,
      saveToken: tokenService.updateToken
    )

    bootstrapper.bootstrap()

    return true
  }

  func applyTheme() {
    let gitterColor = UIColor(red: 232/255, green: 33/255, blue: 102/255, alpha: 1)
    UIView.appearance().tintColor = gitterColor
  }

  func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
    return authorizationCodeParser.parseAndHandleToken(url)
  }
}
