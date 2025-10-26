//
//  FeedUIComposer.swift
//  EssentialFeed
//
//  Created by Mukesh Kondreddy on 26/10/25.
//

import EssentialFeed

public final class FeedUIComposer {
    private init() {}
    
    public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let refreshController = FeedRefreshViewController(loader: feedLoader)

        let feedController = FeedViewController(refreshController: refreshController)
        
        refreshController.onRefresh = { [weak feedController] feed in
            
            feedController?.tableModel = feed.map { model in
                FeedImageCellController(model: model, imageLoader: imageLoader)
            }
        }
        
        return feedController
    }
}
