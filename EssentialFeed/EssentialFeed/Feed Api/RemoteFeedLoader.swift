//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Mavlon Ergashev on 12/01/25.
//

import Foundation

public protocol HttpClient {
    func get(from url: URL)
}

public final class RemoteFeedLoader {
    private let url: URL
    private let client: HttpClient
    
    public init(url: URL, client: HttpClient) {
        self.client = client
        self.url = url
    }
    
    public func load() {
        client.get(from: url)
    }
}
