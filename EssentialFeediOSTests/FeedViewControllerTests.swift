//
//  EssentialFeediOSTests.swift
//  EssentialFeediOSTests
//
//  Created by Mukesh Nagi Reddy on 20/09/25.
//

import UIKit
import XCTest
import EssentialFeed
import EssentialFeediOS

final class FeedViewControllerTests: XCTestCase {
    
    func test_loadFeedActions_requestFeedFromLoader() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        sut.replaceUIRefreshControlWithFake()
        XCTAssertEqual(loader.loadCallCount, 0, "Expected no loading requests before view appears")
        
        sut.beginAppearanceTransition(true, animated: false)
        sut.endAppearanceTransition()
        XCTAssertEqual(loader.loadCallCount, 1, "Expected a loading request after view appears")
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadCallCount, 2, "Expected another loading request after once user initiates a reload")
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadCallCount, 3, "Expected yet another loading request after once user initiates a reload")
    }
    
    func test_loadingFeedIndicator_isVisibleWhileLoadingFeed() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        sut.replaceUIRefreshControlWithFake()
        sut.beginAppearanceTransition(true, animated: false)
        sut.endAppearanceTransition()

        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once view appears")
        
        loader.completeFeedLoading(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once the load is completed")
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once user initiated a reload")
        
        loader.completeFeedLoading(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once the load is completed")
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedViewController(loader: loader)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }
    
    class LoaderSpy: FeedLoader {
        private var completions = [(FeedLoader.Result) -> Void]()
        var loadCallCount: Int {
            completions.count
        }
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            completions.append(completion)
        }
        
        func completeFeedLoading(at index: Int = 0) {
            completions[index](.success([]))
        }
    }

}

private class FakeRefreshControl: UIRefreshControl {
    private var _isRrefreshing: Bool = false
    
    override var isRefreshing: Bool { _isRrefreshing }
    
    override func beginRefreshing() {
        _isRrefreshing = true
    }
    
    override func endRefreshing() {
        _isRrefreshing = false
    }
}

private extension FeedViewController {
    
    var isShowingLoadingIndicator: Bool {
        return refreshControl?.isRefreshing == true
    }
    
    func replaceUIRefreshControlWithFake() {
        let fake = FakeRefreshControl()
        
        refreshControl?.allTargets.forEach { target in
            refreshControl?.actions(forTarget: target, forControlEvent: .valueChanged)?.forEach { action in
                fake.addTarget(target, action: Selector(action), for: .valueChanged)
            }
        }
        
        refreshControl = fake
    }
    
    func simulateUserInitiatedFeedReload() {
        refreshControl?.simulatePullToRefresh()
    }
}

extension UIRefreshControl {
    func simulatePullToRefresh() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}
