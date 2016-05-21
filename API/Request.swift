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
import Alamofire
import ReactiveAlamofire

public struct Request<Response, Resource, Error: APIErrorType> {
  public var path: String
  public var method: Alamofire.Method
  public var parameters: [String: AnyObject]?
  public var encoding: ParameterEncoding
  public var headers: [String: String]?
  public var parser: Response -> ReactiveKit.Result<Resource, Error>

  public init(path: String, method: Alamofire.Method, parameters: [String: AnyObject]? = nil, encoding: ParameterEncoding = .URL, headers: [String: String]? = nil, parser: Response -> ReactiveKit.Result<Resource, Error>) {
    self.path = path
    self.method = method
    self.parameters = parameters
    self.encoding = encoding
    self.headers = headers
    self.parser = parser
  }

  public init(path: String, method: Alamofire.Method, parameters: [String: AnyObject?]? = nil, encoding: ParameterEncoding = .URL, headers: [String: String]? = nil, parser: Response -> ReactiveKit.Result<Resource, Error>) {
    self.init(path: path, method: method, parameters: parameters?.filterNils(), encoding: encoding, headers: headers, parser: parser)
  }
}

public protocol RequestType {
  associatedtype Response
  associatedtype Resource
  associatedtype Error: APIErrorType
  var unbox: Request<Response, Resource, Error> { get }
}

extension Request: RequestType {
  public var unbox: Request<Response, Resource, Error> {
    return self
  }
}

extension RequestType where Response == AnyObject {

  public func toOperationIn(api: APIBase) -> Operation<Resource, Error> {
    return api.toAlamofireRequest(self.unbox).toJSONOperation().map { self.unbox.parser($0) }.dematerialize { error in
      return Error(error: error.localizedDescription)
    }
  }

  public func toStreamingOperationIn(api: APIBase) -> Operation<Resource, Error> {
    return api.toAlamofireRequest(self.unbox).toJSONStreamingOperation().map { self.unbox.parser($0) }.dematerialize { error in
      return Error(error: error.localizedDescription)
    }
  }
}
