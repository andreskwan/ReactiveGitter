//
//  Extensions.swift
//  ReactiveGitter
//
//  Created by Srdan Rasic on 15/05/16.
//  Copyright © 2016 Srdan Rasic. All rights reserved.
//

import Foundation

extension NSAttributedString {

  convenience init(html: String) throws {
    guard let data = NSAttributedString.styledHTMLwithHTML(html).dataUsingEncoding(NSUTF8StringEncoding) else {
      throw NSError(domain: "Invalid HTML", code: -500, userInfo: nil)
    }

    let options = [NSDocumentTypeDocumentAttribute : NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: NSNumber(unsignedInteger:NSUTF8StringEncoding)]
    try self.init(data: data, options: options, documentAttributes: nil)
  }

  static func styledHTMLwithHTML(html: String) -> String {
    return "<meta charset=\"UTF-8\"><style> body { font-family: 'HelveticaNeue'; font-size: 16px; } b {font-family: 'MarkerFelt-Wide'; }</style><body>" + html + "</body>";
  }
}
