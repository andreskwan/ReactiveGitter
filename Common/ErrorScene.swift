//
//  ErrorScene.swift
//  ReactiveGitter
//
//  Created by Srdan Rasic on 20/05/16.
//  Copyright © 2016 Srdan Rasic. All rights reserved.
//

import UIKit

public class ErrorScene {

  let context: Context
  let error: String

  public init(context: Context, error: String) {
    self.context = context
    self.error = error
  }

  public func presentInContext() {
    let alertController = UIAlertController(title: "Error", message: error, preferredStyle: .ActionSheet)
    alertController.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
    context.present(alertController)
  }
}
