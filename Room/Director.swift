//
//  Director.swift
//  ReactiveGitter
//
//  Created by Srdan Rasic on 14/05/16.
//  Copyright © 2016 Srdan Rasic. All rights reserved.
//

import ReactiveKit
import API

class Director {

  enum State {
    case Loading
    case Empty
    case Loaded
  }

  let cellViewModels: Stream<[MessageCell.ViewModel]>
  let title: Stream<String>
  let isActive: Stream<Bool>
  let state: Stream<State>

  init(api: API, room: Stream<Room>, actions: Stage.Actions) {
    title = room.map { $0.name }
    let activityListener = PushStream<Bool>()

    let messages = room.flatMapLatest { room -> Operation<[Message], Error> in
      let oldestMessageWeHave = Property<Message?>(nil)

      // load additional page on each `loadMoreMessages` event
      let existingMessages = actions.loadMoreMessages
        .zipWith(oldestMessageWeHave)
        .flatMapLatest { (_, oldestMessageWeHave) in
          Room.index[room.id].messages
            .query(position: oldestMessageWeHave.flatMap { .BeforeId($0.id) }, limit: 20)
            .toOperationIn(api)
            .feedActivityInto(activityListener)
        }
        .feedNextInto(oldestMessageWeHave, when: { $0.first != nil }, map: { $0.first! })
        .scan([]) { $1 + $0 }

      // use streaming api to listen for new messages
      let newMessages = Room.index[room.id].messages.stream()
        .toStreamingOperationIn(api.streamingAPI)
        .retry(3)
        .map { [$0] }
        .scan([], +)

      // messages = existing messages + new messages
      return existingMessages.combineLatestWith(newMessages).map { $0 + $1 }
    }
    .toStream(justLogError: true)
    .skip(1)
    .shareReplay(1)

    isActive = activityListener.toStream()
    cellViewModels = messages.map { $0.map(MessageCell.ViewModel.init) }
    state = Stream.just(.Loading).mergeWith(messages.map { $0.isEmpty ? .Empty : .Loaded })
  }
}
