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

public struct UnreadItem {
  public let chat: [Room.Resource.Identifier]
  public let mention: [Room.Resource.Identifier]
}

extension UnreadItem {

  public struct Resource: ResourceType {

    public let path: String
    public typealias Identifier = Void

    public init(path: String) {
      self.path = path
    }
  }
}

extension IndexType where Resource == UnreadItem.Resource {

  public func get() -> Request<AnyObject, UnreadItem, Error> {
    return Request(path: path, method: .GET, parser: UnreadItem.parseJSON)
  }

  public func markAsRead(chats: [Room.Resource.Identifier]) -> Request<AnyObject, SuccessResponse, Error>  {
    return Request(path: path, method: .POST, parameters: ["chat": chats], parser: SuccessResponse.parseJSON)
  }
}

// MARK: - Coders

extension UnreadItem: JSONDecodable {

  public init(object: JSONObject) throws {
    let decoder = JSONDecoder(object: object)
    chat = try decoder.decode("chat")
    mention = try decoder.decode("mention")
  }
}
