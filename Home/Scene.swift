//
//  Scene.swift
//  ReactiveGitter
//
//  Created by Srdan Rasic on 11/05/16.
//  Copyright © 2016 Srdan Rasic. All rights reserved.
//

import ReactiveKit
import ReactiveUIKit
import API
import Room
import Common

public class Scene {

  let api: API
  let navigationContext: NavigationContext

  let pWantsLogout = PushStream<Void>()
  public var wantsLogout: Stream<Void> {
    return pWantsLogout.toStream()
  }

  public init(context: NavigationContext, api: API) {
    self.api = api
    self.navigationContext = context
  }

  public func presentInContext() {
    navigationContext.push(stage())
  }
  
  func stage() -> UIViewController {
    return Stage.create { stage in

      let confirm = { (question: String) -> Stream<Bool> in
        let scene = ConfirmationScene.init(context: self.navigationContext, question: question)
        scene.presentInContext()
        return scene.userResponse
      }

      let director = Director(api: self.api, actions: stage.actions, confirm: confirm)

      director.roomToPresent.observeNext { room in
        RoomScene(context: self.navigationContext, api: self.api, room: .just(room)).presentInContext()
      }.disposeIn(stage.rBag)

      director.error.observeNext { error in
        ErrorScene(context: self.navigationContext, error: error).presentInContext()
      }.disposeIn(stage.rBag)

      director.logout.bindTo(self.pWantsLogout)
      return director
    }
  }
}
