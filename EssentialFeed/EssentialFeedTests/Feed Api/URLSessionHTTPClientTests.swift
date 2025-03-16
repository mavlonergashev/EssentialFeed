//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Mavlon Ergashev on 16/03/25.
//

import XCTest

class URLSesssionHTTPClient {
    private let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    func get(from url: URL) {
        session.dataTask(with: url) { _, _, _ in }
    }
}

class URLSessionHTTPClientTests: XCTestCase {

    func test() {
        let url = URL(string: "http://any0url.com")!
        let session = URLSessionSpy()
        let sut = URLSesssionHTTPClient(session: session)
        
        sut.get(from: url)
        
        XCTAssertEqual(session.receivedURLs, [url])
    }
    
    //MARK: -Helpers

    private class URLSessionSpy: URLSession {
        
        var receivedURLs = [URL]()
        
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            receivedURLs.append(url)
            return FakeURLSessionDataTask()
        }
    }
    
    private class FakeURLSessionDataTask: URLSessionDataTask { }
    
}
