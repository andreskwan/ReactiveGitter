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

import ReactiveKit
import JSONCodable
import Alamofire

public protocol PathIdentifiable {
  var path: String { get }
}

public protocol ResourceType: PathIdentifiable {
  associatedtype Identifier
  init(path: String)
}

public protocol IndexType: PathIdentifiable {
  associatedtype Resource: ResourceType
  func resource(id: Resource.Identifier) -> Resource
}

public struct Index<R: ResourceType>: IndexType {
  public let path: String

  public func resource(id: R.Identifier) -> R {
    return R(path: path / "\(id)")
  }

  public subscript (id: R.Identifier) -> R {
    return resource(id)
  }
}

extension String {
  public func appendPathComponent(pathComponent: String) -> String {
    return NSString(string: self).stringByAppendingPathComponent(pathComponent)
  }
}

public func /(left: String, right: String) -> String {
  return left.appendPathComponent(right)
}

extension Dictionary where Value: OptionalType {
  
  public func filterNils() -> [Key: Value.Wrapped] {
    let nonNils = self.filter { $1._unbox != nil }
    var dict: [Key: Value.Wrapped] = [:]
    for (key, value) in nonNils {
      dict[key] = value._unbox!
    }
    return dict
  }
}

extension JSONDecodable {

  static func parseJSON(json: AnyObject) -> ReactiveKit.Result<Self, Error> {
    guard let json = json as? JSONObject else {
      return Result(error: Error(error: "Not a JSONObject"))
    }

    if let error = try? Error(object: json) {
      return Result(error: error)
    } else {
      do {
        let value = try Self(object: json)
        return Result(value: value)
      } catch let error as JSONDecodableError {
        return Result(error: Error(error: error.description))
      } catch {
        return Result(error: Error(error: "Unknown parsing error"))
      }
    }
  }
}

extension Array where Element: JSONDecodable {
  static func parseJSON(json: AnyObject) -> ReactiveKit.Result<Array<Element>, Error> {
    if let jsonArray = json as? [AnyObject] {
      do {
        let array = try Array(JSONArray: jsonArray)
        return Result(value: array)
      } catch let error as JSONDecodableError {
        return Result(error: Error(error: error.description))
      } catch {
        return Result(error: Error(error: "Unknown parsing error"))
      }
    } else if let json = json as? JSONObject, error = try? Error(object: json) {
      return Result(error: error)
    } else {
      return Result(error: Error(error: "Expected JSON Array"))
    }
  }
}

private let dateTimeFormatter: NSDateFormatter = {
  let formatter = NSDateFormatter()
  formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZ"
  formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
  formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
  return formatter
}()

let JSONDateTransformer = JSONTransformer<String, NSDate>(
  decoding: {dateTimeFormatter.dateFromString($0)},
  encoding: {dateTimeFormatter.stringFromDate($0)}
)

let JSONURLTransformer = JSONTransformer<String, NSURL>(
  decoding: {NSURL(string: $0)},
  encoding: {$0.absoluteString}
)

