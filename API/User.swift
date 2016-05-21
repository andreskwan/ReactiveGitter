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

public struct User {
  public let id: String              // Gitter User ID.
  public let username: String        // Gitter/GitHub username.
  public let displayName: String     // Gitter/GitHub user real name.
  public let url: String             // Path to the user on Gitter.
  public let avatarUrlSmall: String  // User avatar URI (small).
  public let avatarUrlMedium: String // User avatar URI (medium).
}
extension User {

  public static var index: Index<Resource> {
    return Index(path: "user")
  }

  public struct Resource: ResourceType {

    public typealias Identifier = String
    public let path: String

    public init(path: String) {
      self.path = path
    }

    public var rooms: Index<Room.Resource> {
      return Index(path: path / "rooms")
    }

    public var channels: Index<Room.Resource> {
      return Index(path: path / "channels")
    }

    public func get() -> Request<AnyObject, User, Error> {
      return Request(path: path, method: .GET, parser: User.parseJSON)
    }

    public func delete() -> Request<AnyObject, SuccessResponse, Error> {
      return Request(path: path, method: .DELETE, parser: SuccessResponse.parseJSON)
    }
  }
}

extension IndexType where Resource == User.Resource {

  public func get(limit: Int? = nil, skip: Int? = nil) -> Request<AnyObject, [User], Error> {
    let parameters: [String: AnyObject?] = ["limit": limit, "skip": skip]
    return Request(path: path, method: .GET, parameters: parameters, parser: [User].parseJSON)
  }

  public func query(q: String, limit: Int? = nil, skip: Int? = nil) -> Request<AnyObject, [User], Error> {
    let parameters: [String: AnyObject?] = ["q": q, "limit": limit, "skip": skip]
    return Request(path: path, method: .GET, parameters: parameters, parser: [User].parseJSON)
  }
}

extension User: JSONDecodable {

  public init(object: JSONObject) throws {
    let decoder = JSONDecoder(object: object)
    id = try decoder.decode("id")
    username = try decoder.decode("username")
    displayName = try decoder.decode("displayName")
    url = try decoder.decode("url")
    avatarUrlSmall = try decoder.decode("avatarUrlSmall")
    avatarUrlMedium = try decoder.decode("avatarUrlMedium")
  }
}
