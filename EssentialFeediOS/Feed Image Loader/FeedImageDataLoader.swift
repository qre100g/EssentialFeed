//
//  FeedImageDataLoader.swift
//  EssentialFeed
//
//  Created by Mukesh Kondreddy on 26/10/25.
//

import Foundation

public protocol FeedImageDataLoaderTask {
    func cancel()
}

public protocol FeedImageDataLoader {
    typealias Result = Swift.Result<Data, Error>

    func loadImageData(from url: URL, completion: @escaping (Result) -> Void) -> FeedImageDataLoaderTask
}
