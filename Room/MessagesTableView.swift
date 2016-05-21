//
//  TableView.swift
//  ReactiveGitter
//
//  Created by Srdan Rasic on 17/05/16.
//  Copyright © 2016 Srdan Rasic. All rights reserved.
//

import UIKit
import ReactiveKit

class MessagesTableView: UITableView {

  private var infoLabel: UILabel? = nil

  private func showInfoLabel(text: String) {
    guard infoLabel == nil else {
      infoLabel!.text = text
      return
    }

    let label = UILabel(frame: bounds)
    label.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
    label.text = text
    label.textAlignment = .Center
    addSubview(label)
    infoLabel = label
  }

  private func hideInfoLabel() {
    infoLabel?.removeFromSuperview()
    infoLabel = nil
  }

  var stateObserver: ObserverWith<MessagesTableView, Director.State> {
    return ObserverWith(self) { s, state in
      switch state {
      case .Loading:
        //s.showInfoLabel("Loading...")
        s.hideInfoLabel()
      case .Empty:
        s.showInfoLabel("No messages.")
      case .Loaded:
        s.hideInfoLabel()
      }
    }
  }

  var loadMoreMessages: Stream<Void> {
    return rDelegate
      .streamFor(#selector(UITableViewDelegate.scrollViewDidScroll(_:)),
        map: { (scrollView: UIScrollView) -> (CGFloat, CGFloat) in (scrollView.contentOffset.y, scrollView.contentInset.top) })
      .map { $0 < -$1 }
      .distinct()
      .filter { $0 }
      .eraseType()
  }

  /// Reloads data and scrolls to bottom if user was alread on bottom.
  override func reloadData() {
    let wasOnBottom = contentOffset.y > contentSize.height - bounds.size.height - 10
    let wasOnTop = contentOffset.y <= 0
    let previousNumberOfItems = numberOfRowsInSection(0)

    super.reloadData()

    let numberOfItems = numberOfRowsInSection(0)
    let isNewMessage = numberOfItems - previousNumberOfItems == 1
    let numberOfNewItems = numberOfItems - previousNumberOfItems
    let isFirstDataLoad = numberOfNewItems > 0 && previousNumberOfItems == 0

    if (isNewMessage && wasOnBottom) || isFirstDataLoad {
      let lastRowIndexPath = NSIndexPath(forRow: numberOfItems - 1, inSection: 0)
      if lastRowIndexPath.row > 0 {
        scrollToRowAtIndexPath(lastRowIndexPath, atScrollPosition: .Bottom, animated: false)
      }
    } else if !isNewMessage && wasOnTop && numberOfNewItems > 0 {
      let tenthRowIndex = NSIndexPath(forRow: numberOfNewItems, inSection: 0)
      if tenthRowIndex.row < numberOfItems {
        scrollToRowAtIndexPath(tenthRowIndex, atScrollPosition: .Top, animated: false)
        UIView.animateWithDuration(0.125) {
          self.contentOffset.y -= 20
        }
      }
    }
  }
}
