//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Mavlon Ergashev on 19/12/24.
//

import XCTest

class RemoteFeedLoader {
    func load() {
        HttpClient.shared.get(from: URL(string: "https://a-url.com")!)
    }
}

class HttpClient {
    static var shared = HttpClient()
        
    func get(from url: URL) {

    }
}

class HttpClientSpy: HttpClient {
    override func get(from url: URL) {
        requestedURL = url
    }
    
    var requestedURL: URL?
}

class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        let client = HttpClientSpy()
        HttpClient.shared = client
        _ = RemoteFeedLoader()
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestDataFromURL() {
        let client = HttpClientSpy()
        HttpClient.shared = client
        let sut = RemoteFeedLoader()
        
        sut.load()
        
        XCTAssertNotNil(client.requestedURL)
    }
    
}
