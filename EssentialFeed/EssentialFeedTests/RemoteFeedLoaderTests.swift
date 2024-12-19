//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Mavlon Ergashev on 19/12/24.
//

import XCTest

class RemoteFeedLoader {
    func load() {
        HttpClient.shared.requestedURL = URL(string: "https://a-url.com")
    }
}

class HttpClient {
    static let shared = HttpClient()
    
    private init() { }
    
    var requestedURL: URL?
}

class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        let client = HttpClient.shared
        _ = RemoteFeedLoader()
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestDataFromURL() {
        let client = HttpClient.shared
        let sut = RemoteFeedLoader()
        
        sut.load()
        
        XCTAssertNotNil(client.requestedURL)
    }
    
}
