//
//  Director.swift
//  ReactiveGitter
//
//  Created by Srdan Rasic on 11/05/16.
//  Copyright © 2016 Srdan Rasic. All rights reserved.
//

import ReactiveKit
import API

private let logoutConfirmationText = "Are you sure you want to logout?"

class Director {

  let cellViewModels: Stream<[RoomCell.ViewModel]>
  let roomToPresent: Stream<Room>
  let logout: Stream<Void>
  let isActive: Stream<Bool>
  let error: Stream<String>
  
  init(api: API, actions: Stage.Actions, confirm: String -> Stream<Bool>) {

    let currentRooms = Property<[Room]>([])
    let activityListener = PushStream<Bool>()
    let errors = PushStream<Error>()

    let leftRoom = actions.leaveRoom.withLatestFrom(currentRooms)
      .map { (index, rooms) in
        return rooms[index]
      }
      .flatMapLatest { room in
        return User.index.get().toOperationIn(api)
          .map { $0.first! }
          .flatMapLatest { user in
            return Room.index[room.id].users[user.id].delete().toOperationIn(api)
          }
          .feedActivityInto(activityListener)
      }
      .eraseType()

    // rooms are refetched upon refresh or upon leaving a room
    let rooms = actions.refresh.toOperation()
      .startWith()
      .mergeWith(leftRoom)
      .flatMapLatest { _ in
        return Room.index.get()
          .toOperationIn(api)
          .feedActivityInto(activityListener)
      }
      .feedNextInto(currentRooms)
      .toStream(feedErrorInto: errors)
      .shareReplay(1)

    cellViewModels = rooms.map { $0.map(RoomCell.ViewModel.init) }
    roomToPresent = actions.selectedRow.withLatestFrom(rooms).map { row, rooms in rooms[row] }
    logout = actions.logout.flatMapLatest { confirm(logoutConfirmationText) }.filter { $0 }.eraseType()
    isActive = activityListener.toStream()
    error = errors.map { $0.error }
  }
}
