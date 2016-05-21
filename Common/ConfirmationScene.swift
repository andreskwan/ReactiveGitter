//
//  ConfirmationScene.swift
//  ReactiveGitter
//
//  Created by Srdan Rasic on 21/05/16.
//  Copyright © 2016 Srdan Rasic. All rights reserved.
//

import UIKit
import ReactiveKit

public class ConfirmationScene {

  let context: Context
  let question: String

  let pUserResponse = PushStream<Bool>()
  public var userResponse: Stream<Bool> {
    return pUserResponse.toStream()
  }

  public init(context: Context, question: String) {
    self.context = context
    self.question = question
  }

  public func presentInContext() {
    let alertController = UIAlertController(title: nil, message: question, preferredStyle: .ActionSheet)
    alertController.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { _ in self.pUserResponse.next(true) }))
    alertController.addAction(UIAlertAction(title: "No", style: .Cancel, handler: { _ in self.pUserResponse.next(false) }))
    context.present(alertController)
  }
}
