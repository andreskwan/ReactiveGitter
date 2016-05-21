//
//  RoomCell.swift
//  ReactiveGitter
//
//  Created by Srdan Rasic on 13/05/16.
//  Copyright © 2016 Srdan Rasic. All rights reserved.
//

import UIKit
import API

class RoomCell: UITableViewCell {

  struct ViewModel {
    let name: String
    let topic: String
  }

  var viewModel: ViewModel? {
    didSet {
      textLabel?.text = viewModel?.name
      detailTextLabel?.text = viewModel?.topic
    }
  }
}

extension RoomCell.ViewModel {

  init(room: Room) {
    name = room.name
    topic = room.topic
  }
}
