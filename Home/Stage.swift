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

typealias Stage = HomeStage
class HomeStage: DirectedViewController<Director>, UITableViewDelegate {

  @IBOutlet weak var logoutBarButton: UIBarButtonItem!
  @IBOutlet weak var tableView: UITableView!
  var refreshControl: UIRefreshControl! = nil

  static func create(directorFactory: Stage -> Director) -> Stage {
    return create(UIStoryboard(name: "Stage", bundle: NSBundle(forClass: Director.self)), directorFactory: downcast(directorFactory)) as! Stage
  }

  override func viewDidLoad() {
    // removes separators from empty cells
    tableView.tableFooterView = UIView()

    refreshControl = UIRefreshControl()
    tableView.addSubview(refreshControl)
    tableView.rDelegate.forwardTo = self

    super.viewDidLoad()
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    if let selectedRow = tableView.indexPathForSelectedRow {
      tableView.deselectRowAtIndexPath(selectedRow, animated: true)
    }
  }

  override func bindDirector(director: Director) {
    bind(director.isActive, to: refreshControl.rRefreshing)
    bind(director.isActive, to: UIApplication.sharedApplication().rNetworkActivityIndicatorVisible)

    director.cellViewModels.bindTo(tableView) { indexPath, data, tableView in
      let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! RoomCell
      cell.viewModel = data[indexPath.row]
      return cell
    }
  }

  // UITableViewDelegate forwarding example. Notice `tableView.rDelegate.forwardTo = self` in `viewDidLoad`.

  func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String? {
    return "Leave"
  }
}

private extension UITableView {

  var selectedRow: Stream<Int> {
    return rDelegate.streamFor(#selector(UITableViewDelegate.tableView(_:didSelectRowAtIndexPath:))) { (a: UITableView, b: NSIndexPath) in b.row }
  }

  var leaveRoomAtIndexPath: Stream<Int> {
    return rDataSource.streamFor(#selector(UITableViewDataSource.tableView(_:commitEditingStyle:forRowAtIndexPath:))) { (_: UITableView, _: UITableViewCellEditingStyle, indexPath: NSIndexPath) in indexPath.row }
  }
}
extension Stage {

  struct Actions {
    let logout: Stream<Void>
    let selectedRow: Stream<Int>
    let leaveRoom: Stream<Int>
    let refresh: Stream<Void>
  }

  var actions: Actions {
    return Actions(
      logout: logoutBarButton.rTap,
      selectedRow: tableView.selectedRow,
      leaveRoom: tableView.leaveRoomAtIndexPath,
      refresh: refreshControl.rRefreshing.filter { $0 }.eraseType()
    )
  }
}
