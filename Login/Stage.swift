//
//  Stage.swift
//  ReactiveGitter
//
//  Created by Srdan Rasic on 11/05/16.
//  Copyright © 2016 Srdan Rasic. All rights reserved.
//

import Common
import ReactiveKit
import ReactiveUIKit

typealias Stage = LoginStage
class LoginStage: DirectedViewController<Director> {

  @IBOutlet weak var loginButton: UIButton!
  @IBOutlet weak var errorLabel: UILabel!

  init(directorFactory: Stage -> Director) {
    super.init(nibName: "Stage", bundle: NSBundle(forClass: Director.self), directorFactory: downcast(directorFactory))
  }
  
  override func prefersStatusBarHidden() -> Bool {
    return true
  }

  override func bindDirector(director: Director) {
    bind(director.error, to: errorLabel)
    bind(director.error.map { $0.isEmpty }, to: errorLabel.rHidden)
  }
}
