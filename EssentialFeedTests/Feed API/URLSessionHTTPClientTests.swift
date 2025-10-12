//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Mukesh Nagi Reddy on 14/06/25.
//

import XCTest
import EssentialFeed

class URLSessionHTTPClientTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        URLProtocolSpy.startInterceptingRequests()
    }
    
    override func tearDown() {
        super.tearDown()
        
        URLProtocolSpy.stopInterceptingRequests()
    }
    
    func test_getFromURL_requestsURL() {
        let exp = expectation(description: "Wait for the completion")
        let url = URL(string: "https://example-url.com,")!
        
        URLProtocolSpy.addRequestObserver { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            
            exp.fulfill()
        }
        
        makeSUT().get(from: url) { _ in }
        
        wait(for: [exp], timeout: 1.0)
    }
  
    func test_getFromURL_failsOnRequestError() {
        let error = NSError(domain: "Error", code: 100, userInfo: nil)
        
        let receivedError = requestErrorFor(data: nil, response: nil, error: error) as NSError
        
        XCTAssertEqual(receivedError.domain, error.domain)
        XCTAssertEqual(receivedError.code, error.code)
    }
    
    func test_getFromURL_failsOnAllInvalidCases() {
        XCTAssertNotNil(requestErrorFor(data: nil, response: nil, error: nil))
        XCTAssertNotNil(requestErrorFor(data: nil, response: anyNonHTTPResponse(), error: nil))
        XCTAssertNotNil(requestErrorFor(data: nil, response: anyNonHTTPResponse(), error: anyError()))
        XCTAssertNotNil(requestErrorFor(data: nil, response: anyHTTPURLResponse(), error: anyError()))
        XCTAssertNotNil(requestErrorFor(data: anyData(), response: nil, error: nil))
        XCTAssertNotNil(requestErrorFor(data: anyData(), response: anyNonHTTPResponse(), error: nil))
        XCTAssertNotNil(requestErrorFor(data: anyData(), response: anyNonHTTPResponse(), error: anyError()))
        XCTAssertNotNil(requestErrorFor(data: anyData(), response: anyHTTPURLResponse(), error: anyError()))
    }
    
    func test_getFromURL_deliversDataWithURLResponseForHappyPath() {
        let data = Data("Hello world".utf8)
        let response = anyHTTPURLResponse()
        
        let values = requestValueFor(data: data, response: response)
        
        XCTAssertEqual(values.data, data)
        XCTAssertEqual(values.response.statusCode, response.statusCode)
        XCTAssertEqual(values.response.url, response.url)
    }
    
    func test_getFromURL_deliversDataWithURLResponseForEmptyData() {
        let response = anyHTTPURLResponse()
        let emptyData = Data()
        
        let values = requestValueFor(data: nil, response: response)

        XCTAssertEqual(values.data, emptyData)
        XCTAssertEqual(values.response.statusCode, response.statusCode)
        XCTAssertEqual(values.response.url, response.url)
    }
  
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> HTTPClient {
        let sut = URLSessionHTTPClient()
        trackForMemoryLeaks(sut)
        return sut
    }
    
    private func requestErrorFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #filePath, line: UInt = #line) -> Error {
        var requestError: Error!
        
        let result = requestResultFor(data: data, response: response, error: error, file: file, line: line)
        
        switch result {
        case let .failure(error):
            requestError = error
        default:
            XCTFail("Unexpected result: \(result)")
        }
        
        return requestError
    }
    
    private func requestValueFor(data: Data?, response: URLResponse, file: StaticString = #filePath, line: UInt = #line) -> (data: Data, response: HTTPURLResponse) {
        var requestedValue: (Data, HTTPURLResponse)!
        
        let result = requestResultFor(data: data, response: response, error: nil, file: file, line: line)
        
        switch result {
        case let .success((data, response)):
            requestedValue = (data, response)
        default:
            XCTFail("Unexpected result: \(result)")
        }
        
        return requestedValue
    }
    
    private func requestResultFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #filePath, line: UInt = #line) -> HTTPClient.Result {
        let url = anyURL()
        let exp = expectation(description: "Wait for expectation")
        
        URLProtocolSpy.stub(url, data: data, response: response, error: error)
        
        var receivedResult: HTTPClient.Result!
        makeSUT(file: file, line: line).get(from: url) { result in
            receivedResult = result
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        
        return receivedResult
    }
    
    private func anyNonHTTPResponse() -> URLResponse {
        let url = URL(string: "https://example.com")!
        return URLResponse(url: url, mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    
    private func anyHTTPURLResponse() -> HTTPURLResponse {
        let url = URL(string: "https://example.com")!
        return HTTPURLResponse(url: url, mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    
    private func anyData() -> Data {
        return Data()
    }
    
    private func anyURL() -> URL {
        return URL(string: "https://example.com")!
    }
    
    private func anyError() -> Error {
        return NSError(domain: "Domain", code: 0)
    }
  
    private class URLProtocolSpy: URLProtocol {
        static var stubs: [URL: Stub] = [:]
        static var requestObserver: ((URLRequest) -> Void)?
    
        struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
        }
    
        static func stub(_ url: URL, data: Data?, response: URLResponse?, error: Error?) {
            self.stubs[url] = Stub(data: data, response: response, error: error)
        }
      
        static func addRequestObserver(_ observer: @escaping (URLRequest) -> Void) {
            requestObserver = observer
        }
    
        static func startInterceptingRequests() {
            URLProtocol.registerClass(self)
        }
    
        static func stopInterceptingRequests() {
            URLProtocol.unregisterClass(self)
            stubs = [:]
            requestObserver = nil
        }
    
        override class func canInit(with request: URLRequest) -> Bool {
            return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            if let observer = URLProtocolSpy.requestObserver {
                client?.urlProtocolDidFinishLoading(self)
                observer(request)
                return
            }

            guard let url = request.url, let stub = Self.stubs[url] else { return }

            if let data = stub.data {
                client?.urlProtocol(self, didLoad: data)
            }

            if let response = stub.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }

            if let error = stub.error {
                client?.urlProtocol(self, didFailWithError: error)
            }

            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {}
    }
}
