//
//  FeedCacheTestHelpers.swift
//  EssentialFeed
//
//  Created by Mukesh Nagi Reddy on 27/07/25.
//

import Foundation
import EssentialFeed

func anyNSError() -> NSError {
    return NSError(domain: "Domain", code: 0)
}

func uniqueFeedItems() -> (models: [FeedImage], local: [LocalFeedImage]) {
    let images =  [anyFeedImage(), anyFeedImage()]
    let localImages = images.map( { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.imageURL) })

    return (images, localImages)
}

func anyFeedImage() -> FeedImage {
    FeedImage(id: UUID(), description: "anyDesc", location: "anyLocation", imageURL: anyURL())
}

func anyURL() -> URL {
    return URL(string: "anyURL")!
}

extension Date {
    
    private var feedCacheMaxAgeInDays: Int {
        7
    }
    
    func minusFeedCacheMaxAge() -> Date {
        self.adding(days: -feedCacheMaxAgeInDays)
    }
    
    func adding(days: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
    
}

extension Date {
    
    func adding(seconds: TimeInterval) -> Date {
        return self + seconds
    }
}
