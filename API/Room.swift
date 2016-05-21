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

public struct Room {
  public let id: String
  public let name: String            // Room name.
  public let uri: String             // Room URI on Gitter.
  public let topic: String           // Room topic. (default: GitHub repo description)
  public let oneToOne: Bool          // Indicates if the room is a one-to-one chat.
  public let users: [User]           // List of users in the room.
  public let userCount: Int          // Count of users in the room.
  public let unreadItems: Int        // Number of unread messages for the current user.
  public let mentions: Int           // Number of unread mentions for the current user.
  public let lastAccessTime: String  // Last time the current user accessed the room in ISO format.
  public let favourite: Bool         // Indicates if the room is on of your favourites.
  public let lurk: Bool              // Indicates if the current user has disabled notifications.
  public let url: String             // Path to the room on gitter.
  public let githubType: String      // Type of the room.
  public let tags: [String]          // Tags that define the room.
  //public let v: String             // Room version.
}

extension Room {

  public static var index: Index<Room.Resource> {
    return Index(path: "rooms")
  }

  public struct Resource: ResourceType {

    public let path: String
    public typealias Identifier = String

    public init(path: String) {
      self.path = path
    }

    public var channels: Index<Room.Resource> {
      return Index(path: path / "channels")
    }

    public var messages: Index<Message.Resource> {
      return Index(path: path / "chatMessages")
    }

    public var users: Index<User.Resource> {
      return Index(path: path / "users")
    }

    public var unreadItems: Index<UnreadItem.Resource> {
      return Index(path: path / "unreadItems")
    }

    public func get() -> Request<AnyObject, Room, Error> {
      return Request(path: path, method: .GET, parser: Room.parseJSON)
    }

    public func update(topic: String? = nil, noindex: Bool? = nil, tags: String? = nil) -> Request<AnyObject, Room, Error> {
      let parameters = ["topic": topic, "noindex": noindex, "tags": tags] as [String: AnyObject?]
      return Request(path: path, method: .PUT, parameters: parameters, parser: Room.parseJSON)
    }

    public func delete() -> Request<AnyObject, SuccessResponse, Error> {
      return Request(path: path, method: .DELETE, parser: SuccessResponse.parseJSON)
    }
  }
}

extension IndexType where Resource == Room.Resource {

  public func get() -> Request<AnyObject, [Room], Error> {
    return Request(path: path, method: .GET, parser: [Room].parseJSON)
  }

  public func query(q: String) -> Request<AnyObject, [Room], Error> {
    return Request(path: path, method: .GET, parameters: ["q": q], parser: [Room].parseJSON)
  }

  public func join(uri: String) -> Request<AnyObject, Room, Error> {
    return Request(path: path, method: .POST, parameters: ["uri": uri], parser: Room.parseJSON)
  }
}

extension Room: JSONDecodable {

  public init(object: JSONObject) throws {
    let decoder = JSONDecoder(object: object)
    id = try decoder.decode("id")
    name = try decoder.decode("name")
    uri = try decoder.decode("uri")
    topic = try decoder.decode("topic")
    oneToOne = try decoder.decode("oneToOne")
    users = try decoder.decode("users")
    userCount = try decoder.decode("userCount")
    unreadItems = try decoder.decode("unreadItems")
    mentions = try decoder.decode("mentions")
    lastAccessTime = try decoder.decode("lastAccessTime")
    favourite = (try? decoder.decode("favourite")) ?? false
    lurk = try decoder.decode("lurk")
    url = try decoder.decode("url")
    githubType = try decoder.decode("githubType")
    tags = try decoder.decode("tags")
  }
}
