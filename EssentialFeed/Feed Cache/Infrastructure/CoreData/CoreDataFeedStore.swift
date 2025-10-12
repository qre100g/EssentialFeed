//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Mukesh Nagi Reddy on 17/08/25.
//

import Foundation
import CoreData

public class CoreDataFeedStore: FeedStore {
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    public init(storeURL: URL, bundle: Bundle = .main) throws {
        container = try NSPersistentContainer.load(modelName: "FeedStore", url: storeURL, in: bundle)
        context = container.newBackgroundContext()
    }

    public func retrieveCacheFeed(completion: @escaping RetrieveCompletion) {
        perform { context in
            completion(Result {
                try ManagedCache.find(in: context).map {
                    return CacheFeed(feed: $0.localFeed, timestamp: $0.timestamp)
                }
            })
        }
    }
    
    public func deleteCacheFeed(completion: @escaping DeleteCompletion) {
        perform { context in
            completion(Result {
                try ManagedCache.find(in: context).map(context.delete).map(context.save)
                return ()
            })
        }
    }
    
    public func insert(_ images: [LocalFeedImage], timestamp: Date, completion: @escaping InsertCompletion) {
        perform { context in
            completion(Result {
                let managedCache = try ManagedCache.newUniqueInstance(in: context)
                managedCache.timestamp = timestamp
                managedCache.feed = ManagedFeedImage.images(from: images, in: context)
                
                try context.save()
                return ()
            })
        }
    }
    
    private func perform(_ action: @escaping (NSManagedObjectContext) -> Void) {
        let context = self.context
        context.perform { action(context) }
    }
}
