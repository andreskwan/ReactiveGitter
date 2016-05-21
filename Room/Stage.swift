//
//  Stage.swift
//  ReactiveGitter
//
//  Created by Srdan Rasic on 14/05/16.
//  Copyright © 2016 Srdan Rasic. All rights reserved.
//

import Common
import ReactiveKit
import ReactiveUIKit

typealias Stage = RoomStage
class RoomStage: DirectedViewController<Director> {

  @IBOutlet weak var tableView: MessagesTableView!

  static func create(directorFactory: Stage -> Director) -> Stage {
    return create(UIStoryboard(name: "Stage", bundle: NSBundle(forClass: Director.self)), directorFactory: downcast(directorFactory)) as! Stage
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    tableView.tableFooterView = UIView()
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 200
  }

  override func bindDirector(director: Director) {
    bind(director.title, to: navigationItem.rTitle)
    bind(director.isActive, to: UIApplication.sharedApplication().rNetworkActivityIndicatorVisible)
    bind(director.state, to: tableView.stateObserver)

    director.cellViewModels.bindTo(tableView) { indexPath, data, tableView in
      let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! MessageCell
      cell.viewModel = data[indexPath.row]
      return cell
    }
  }
}

extension Stage {

  struct Actions {
    let loadMoreMessages: Stream<Void>
  }

  var actions: Actions {
    return Actions(
      loadMoreMessages: tableView.loadMoreMessages
    )
  }
}
