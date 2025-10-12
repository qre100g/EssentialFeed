//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Mukesh Nagi Reddy on 19/07/25.
//

import Foundation

public class LocalFeedLoader {
    private let store: FeedStore
    private let currentDate: () -> Date
    
    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
}

extension LocalFeedLoader {
    
    public typealias SaveResult = Result<Void, Error>
    
    public func save(_ images: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        store.deleteCacheFeed {[weak self] deletionResult in
            guard let self else { return }
            
            switch deletionResult {
            case .success:
                self.insert(images: images, completion: completion)
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    private func insert(images: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        store.insert(
            images.toLocalFeed(),
            timestamp: self.currentDate(),
            completion: {[weak self] insertionError in
                guard self != nil else { return }
                completion(insertionError)
            }
        )
    }

}

extension LocalFeedLoader: FeedLoader {
    
    public typealias LoadResult = FeedLoader.Result
    
    public func load(completion: @escaping (LoadResult) -> Void) {
        store.retrieveCacheFeed { [weak self] result in
            guard let self else { return }
            switch result {
            case let .failure(error):
                completion(.failure(error))
            case let .success(.some(cache)) where FeedCachePolicy.validate(cache.timestamp, against: currentDate()):
                completion(.success(cache.feed.toModels()))
            case .success:
                completion(.success([]))
            }
        }
    }
}
    
extension LocalFeedLoader {
    
    public func validateCache() {
        store.retrieveCacheFeed {[weak self] result in
            guard let self else { return }

            switch result {
            case .failure:
                store.deleteCacheFeed { _ in }
            case let .success(.some(cache)) where !FeedCachePolicy.validate(cache.timestamp, against: currentDate()):
                store.deleteCacheFeed { _ in }
            case .success:
                break
            }
        }
    }

}

private extension Array where Element == FeedImage {
    func toLocalFeed() -> [LocalFeedImage] {
        map {
            LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.imageURL)
        }
    }
}

private extension Array where Element == LocalFeedImage {
    func toModels() -> [FeedImage] {
        map {
            FeedImage(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.imageURL)
        }
    }
}
