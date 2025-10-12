//
//  FeedCachePolicy.swift
//  EssentialFeed
//
//  Created by Mukesh Nagi Reddy on 30/07/25.
//

import Foundation

enum FeedCachePolicy {
    private static let calender = Calendar(identifier: .gregorian)
    private static let maximumCacheAgeInDays = 7
    
    static func validate(_ timestamp: Date, against date: Date) -> Bool {
        guard let maxCacheAge = calender.date(byAdding: .day, value: maximumCacheAgeInDays, to: timestamp) else {
            return false
        }
        
        return date < maxCacheAge
    }
}
