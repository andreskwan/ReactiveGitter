//
//  Scene.swift
//  ReactiveGitter
//
//  Created by Srdan Rasic on 14/05/16.
//  Copyright © 2016 Srdan Rasic. All rights reserved.
//

import ReactiveKit
import Common
import API

public class RoomScene {

  let api: API
  let room: Stream<Room>
  let navigationContext: NavigationContext

  public init(context: NavigationContext, api: API, room: Stream<Room>) {
    self.api = api
    self.room = room
    self.navigationContext = context
  }

  public func presentInContext() {
    let stage = Stage.create { stage in
      return Director(api: self.api, room: self.room, actions: stage.actions)
    }

    navigationContext.push(stage)
  }
}
