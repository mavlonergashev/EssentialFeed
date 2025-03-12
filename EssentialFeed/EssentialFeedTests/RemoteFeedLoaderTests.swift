//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Mavlon Ergashev on 19/12/24.
//

import XCTest
import EssentialFeed

class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestsDataFromURL() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load(completion: { _ in })
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestsDataFromURLTwice() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load(completion: { _ in })
        sut.load(completion: { _ in })
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWithError: .failure(.connectivity)) {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        }
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        
        let samples = [199, 201, 300, 400, 500]
        
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWithError: .failure(.invalidData)) {
                client.complete(withStatusCode: code, at: index)
            }
        }
        
    }
    
    func test_load_deliversErrorOn200HttpResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWithError: .failure(.invalidData), when: {
            let invalidJSON = Data("invalid json".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON)
        })
    }
    
    func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWithError: .success([])) {
            let emptyListJSON = Data("{\"items\" : []}".utf8)
            client.complete(withStatusCode: 200, data: emptyListJSON)
        }
    }
    
    func test_load_deliversItemsOn200HTTPSResponseWithJSONItems() {
        let (sut, client) = makeSUT()
        
        let item1 = makeItem(
            id: UUID(),
            imageURL: URL(string: "http://a-url.com")!
        )
        
        let item2 = makeItem(
            id: UUID(),
            description: "a description",
            imageURL: URL(string: "http://another-url.com")!
        )
        
        let items = [item1.model, item2.model]
        
        expect(sut, toCompleteWithError: .success(items)) {
            let json = makeItemsJSON([item1.json, item2.json])
            client.complete(withStatusCode: 200, data: json)
        }
    }
    
    
    //MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> (sut: RemoteFeedLoader, client: HttpClientSpy) {
        let client = HttpClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
    
    private func makeItem(id: UUID, description: String? = nil, location: String? = nil, imageURL: URL) -> (model: FeedItem, json: [String: Any]) {
        let item = FeedItem(id: id, description: description, location: location, imageURL: imageURL)
        let json = [
            "id": id.uuidString,
            "description": description,
            "location": location,
            "image": imageURL.absoluteString
        ].compactMapValues { $0 }
        return (item, json)
    }
    
    private func makeItemsJSON(_ items: [[String: Any]]) -> Data {
        let json = ["items": items]
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    private func expect(
        _ sut: RemoteFeedLoader,
        toCompleteWithError result: RemoteFeedLoader.Result,
        when action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        var capturedResults = [RemoteFeedLoader.Result]()
        sut.load { capturedResults.append($0) }
        
        action()
        
        XCTAssertEqual(capturedResults, [result], file: file, line: line)
    }
    
    private class HttpClientSpy: HttpClient {
        private var messages = [(url: URL, completion: (HttpClientResult) -> Void)]()
        
        var requestedURLs: [URL] {
            messages.map { $0.url }
        }
        
        func get(from url: URL, completion: @escaping (HttpClientResult) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code: Int, data: Data = Data(), at index: Int = 0) {
            let httpResponse = HTTPURLResponse(
                url: requestedURLs[index],
                statusCode: code,
                httpVersion: nil,
                headerFields: nil
            )!
            messages[index].completion(.success(data, httpResponse))
        }
        
    }
    
}
