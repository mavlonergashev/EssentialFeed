//
//  HttpClient.swift
//  EssentialFeed
//
//  Created by Mavlon Ergashev on 13/03/25.
//

import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}
