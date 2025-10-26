//
//  FeedViewControllerTests+LoaderSpy.swift
//  EssentialFeed
//
//  Created by Mukesh Kondreddy on 26/10/25.
//

import UIKit
import EssentialFeed
import EssentialFeediOS

class LoaderSpy: FeedLoader, FeedImageDataLoader {
    
    // MARK: - FeedLoader
    
    private var completions = [(FeedLoader.Result) -> Void]()
    var loadFeedCallCount: Int {
        completions.count
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        completions.append(completion)
    }
    
    func completeFeedLoading(with feed: [FeedImage] = [], at index: Int = 0) {
        completions[index](.success(feed))
    }
    
    func completeFeedLoadingWithError(at index: Int = 0) {
        let error = NSError()
        completions[index](.failure(error))
    }
    
    // MARK: - FeedImageDataLoader
    
    struct TaskSpy: FeedImageDataLoaderTask {
        let cancelCallback: () -> Void
        func cancel() {
            cancelCallback()
        }
    }
    
    private var imageRequests = [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)]()
    
    var loadedImageURLs: [URL] {
        imageRequests.map((\.url))
    }

    private(set) var cancelledImageURLs = [URL]()
    
    func loadImageData(
        from url: URL,
        completion: @escaping (FeedImageDataLoader.Result) -> Void
    ) -> FeedImageDataLoaderTask {
        imageRequests.append((url, completion))
        return TaskSpy(cancelCallback: { [weak self] in
            self?.cancelledImageURLs.append(url)
        })
    }
    
    func completeImageLoading(with imageData: Data = Data(), at index: Int = 0) {
        imageRequests[index].completion(.success(imageData))
    }
    
    func completeImageLoadingWithError(at index: Int = 0) {
        let error = NSError()
        imageRequests[index].completion(.failure(error))
    }
}
