//
//  MessageCell.swift
//  ReactiveGitter
//
//  Created by Srdan Rasic on 14/05/16.
//  Copyright © 2016 Srdan Rasic. All rights reserved.
//

import UIKit
import AlamofireImage
import API

class MessageCell: UITableViewCell {

  @IBOutlet weak var authorImageView: UIImageView!
  @IBOutlet weak var authorNameLabel: UILabel!
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var bodyTextView: UITextView!

  struct ViewModel {
    let authorName: String
    let authorPhotoUrl: String
    let date: NSDate
    let body: NSAttributedString
  }

  static let dateFormatter = { () -> NSDateFormatter in
    let formatter = NSDateFormatter()
    formatter.dateStyle = .ShortStyle
    formatter.timeStyle = .ShortStyle
    return formatter
  }()

  var viewModel: ViewModel? {
    didSet {
      authorNameLabel.text = viewModel?.authorName
      dateLabel.text = (viewModel?.date).flatMap { MessageCell.dateFormatter.stringFromDate($0) }
      bodyTextView.attributedText = viewModel?.body

      if let urlString = viewModel?.authorPhotoUrl, url = NSURL(string: urlString) {
        authorImageView.af_setImageWithURL(url, filter: RoundedCornersFilter(radius: 4))
      } else {
        authorImageView.image = nil
      }
    }
  }

  override func awakeFromNib() {
    super.awakeFromNib()
    bodyTextView.textContainerInset = UIEdgeInsetsZero
    bodyTextView.textContainer.lineFragmentPadding = 0
  }
}

extension MessageCell.ViewModel {

  init(message: Message) {
    authorName = message.fromUser.displayName
    authorPhotoUrl = message.fromUser.avatarUrlSmall
    date = message.editedAt ?? message.sent

    if let body = (try? NSAttributedString(html: message.html)) where body.length > 0 {
      self.body = body
    } else {
      body = NSAttributedString(string: "This message was deleted.")
    }
  }
}
