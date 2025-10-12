//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Mukesh Nagi Reddy on 19/07/25.
//

import Foundation

public typealias CacheFeed = (feed: [LocalFeedImage], timestamp: Date)

public protocol FeedStore {
    typealias DeletionResult = Result<Void, Error>
    typealias DeleteCompletion = (DeletionResult) -> Void
    
    typealias InsertionResult = Result<Void, Error>
    typealias InsertCompletion = (DeletionResult) -> Void

    typealias RetrievalResult = Result<CacheFeed?, Error>
    typealias RetrieveCompletion = (RetrievalResult) -> Void
    
    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func deleteCacheFeed(completion: @escaping DeleteCompletion)
    
    /// The completion handler can be invoked in any thread.
    /// Clents are responsible to dispatch to appropriate threads, if needed.
    func insert(_ images: [LocalFeedImage], timestamp: Date, completion: @escaping InsertCompletion)
    
    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func retrieveCacheFeed(completion: @escaping RetrieveCompletion)
}
