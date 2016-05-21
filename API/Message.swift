//
//  The MIT License (MIT)
//
//  Copyright (c) 2015 Srdan Rasic (@srdanrasic)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import JSONCodable

public struct Message {
  public let id: String           // ID of the message.
  public let text: String      // Original message in plain-text/markdown.
  public let html: String      // HTML formatted message.
  public let sent: NSDate      // ISO formatted date of the message.
  public let editedAt: NSDate?  // ISO formatted date of the message if edited.
  public let fromUser: User    // (User)[user-resource] that sent the message.
  public let unread: Bool      // Boolean that indicates if the current user has read the message.
  public let readBy: Int       // Number of users that have read the message.
  public let urls: [Url]    // List of URLs present in the message.
  //mentions: List of @Mentions in the message.
  //issues: List of #Issues referenced in the message.
  //meta: Metadata. This is currently not used for anything.
  //v: Version.
  //gv: Stands for "Gravatar version" and is used for cache busting.

  public struct Url {
    let url: String
  }
}

extension Message {

  public struct Resource: ResourceType {

    public let path: String
    public typealias Identifier = String

    public enum QueryPosition {
      case BeforeId(String)
      case AfterId(String)
      case AroundId(String)
    }

    public init(path: String) {
      self.path = path
    }

    public func get() -> Request<AnyObject, Message, Error> {
      return Request(path: path, method: .GET, parser: Message.parseJSON)
    }

    public func update(text: String) -> Request<AnyObject, Message, Error> {
      return Request(path: path, method: .PUT, parameters: ["text": text], parser: Message.parseJSON)
    }
  }
}

extension IndexType where Resource == Message.Resource {

  public func get(limit: Int? = nil, skip: Int? = nil) -> Request<AnyObject, [Message], Error> {
    let parameters: [String: AnyObject?] = ["limit": limit, "skip": skip]
    return Request(path: path, method: .GET, parameters: parameters, parser: [Message].parseJSON)
  }

  public func stream() -> Request<AnyObject, Message, Error> {
    return Request(path: path, method: .GET, parser: Message.parseJSON)
  }

  public func post(text: String) -> Request<AnyObject, Message, Error> {
    return Request(path: path, method: .POST, parameters: ["text": text], parser: Message.parseJSON)
  }

  public func query(q: String? = nil, position: Message.Resource.QueryPosition? = nil,
                    limit: Int? = nil, skip: Int? = nil) -> Request<AnyObject, [Message], Error> {
    let parameters = [
      "q": q, "limit": limit, "skip": skip, position?.keyValue.0 ?? "": position?.keyValue.1
    ] as [String: AnyObject?]
    return Request(path: path, method: .GET, parameters: parameters, parser: [Message].parseJSON)
  }
}


// MARK: - Coders

extension Message: JSONDecodable {

  public init(object: JSONObject) throws {
    let decoder = JSONDecoder(object: object)
    id = try decoder.decode("id")
    text = try decoder.decode("text")
    html = try decoder.decode("html")
    sent = try decoder.decode("sent", transformer: JSONDateTransformer)
    editedAt = try decoder.decode("editedAt", transformer: JSONDateTransformer)
    fromUser = try decoder.decode("fromUser")
    unread = try decoder.decode("unread")
    readBy = try decoder.decode("readBy")
    urls = try decoder.decode("urls")
  }
}

extension Message.Url: JSONDecodable {

  public init(object: JSONObject) throws {
    let decoder = JSONDecoder(object: object)
    url = try decoder.decode("url")
  }
}

extension Message.Resource.QueryPosition {

  public var keyValue: (String, AnyObject) {
    switch self {
    case .BeforeId(let id):
      return ("beforeId", id)
    case .AfterId(let id):
      return ("afterId", id)
    case .AroundId(let id):
      return ("aroundId", id)
    }
  }
}
