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
        XCTAssertEqual(loader.loadFeedCallCount, 0, "Expected no loading requests before view appears")
        
        sut.beginAppearanceTransition(true, animated: false)
        sut.endAppearanceTransition()
        XCTAssertEqual(loader.loadFeedCallCount, 1, "Expected a loading request after view appears")
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadFeedCallCount, 2, "Expected another loading request after once user initiates a reload")
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadFeedCallCount, 3, "Expected yet another loading request after once user initiates a reload")
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
        
        loader.completeFeedLoadingWithError(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once the loading completes with error")
    }
    
    func test_loadFeedCompletion_rendersSuccessfullyLoadedFeed() {
        let image0 = makeImage(description: "a description", location: "a location")
        let image1 = makeImage(description: nil, location: "another location")
        let image2 = makeImage(description: "another description", location: nil)
        let image3 = makeImage(description: nil, location: nil)
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        sut.beginAppearanceTransition(true, animated: false)
        sut.endAppearanceTransition()
        assertThat(sut, isRenderingWith: [])
        
        loader.completeFeedLoading(with: [image0], at: 0)
        assertThat(sut, isRenderingWith: [image0])
        
        sut.simulateUserInitiatedFeedReload()
        loader.completeFeedLoading(with: [image1, image2, image3], at: 1)
        assertThat(sut, isRenderingWith: [image1, image2, image3])
    }
    
    func test_loadFeedCompletion_doNotAlterCurrentRenderingStateOnError() {
        let image = makeImage()
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        sut.beginAppearanceTransition(true, animated: false)
        sut.endAppearanceTransition()
        
        loader.completeFeedLoading(with: [image], at: 0)
        assertThat(sut, isRenderingWith: [image])
        
        sut.simulateUserInitiatedFeedReload()
        loader.completeFeedLoadingWithError(at: 1)
        assertThat(sut, isRenderingWith: [image])
    }
    
    func test_feedImageView_loadsImageURLWhenVisible() {
        let image0 = makeImage(url: URL(string: "https://url-0.com")!)
        let image1 = makeImage(url: URL(string: "https://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        sut.beginAppearanceTransition(true, animated: false)
        sut.endAppearanceTransition()
        loader.completeFeedLoading(with: [image0, image1], at: 0)
        
        XCTAssertEqual(loader.loadedImageURLs, [], "Expected no image URL requests until view becomes visible")
        
        sut.simulateFeedImageViewVisible(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [image0.imageURL], "Expected first image url request on first view becomes visible")
        
        sut.simulateFeedImageViewVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [image0.imageURL, image1.imageURL], "Expected second image url request on second view becomes visible")
    }
    
    func test_feedImageView_cancelsImageLoadingWhenImageViewNotVisible() {
        let image0 = makeImage(url: URL(string: "https://url-0.com")!)
        let image1 = makeImage(url: URL(string: "https://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        sut.beginAppearanceTransition(true, animated: false)
        sut.endAppearanceTransition()
        loader.completeFeedLoading(with: [image0, image1], at: 0)
        
        XCTAssertEqual(loader.cancelledImageURLs, [], "Expected no image URL requests until view becomes visible")
        
        sut.simulateFeedImageViewNotVisible(at: 0)
        XCTAssertEqual(loader.cancelledImageURLs, [image0.imageURL], "Expected first image url request on first view becomes visible")
        
        sut.simulateFeedImageViewNotVisible(at: 1)
        XCTAssertEqual(loader.cancelledImageURLs, [image0.imageURL, image1.imageURL], "Expected second image url request on second view becomes visible")
    }
    
    func test_feedImageViewLoadingIndicator_isVisibleWhileLoadingImage() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        sut.beginAppearanceTransition(true, animated: false)
        sut.endAppearanceTransition()
        loader.completeFeedLoading(with: [makeImage(), makeImage()], at: 0)
        
        let view0 = sut.simulateFeedImageViewVisible(at: 0)
        let view1 = sut.simulateFeedImageViewVisible(at: 1)
        
        XCTAssertEqual(view0.isShowingImageLoadingIndicator, true, "Expected loading indicator for the first view while loading first view")
        XCTAssertEqual(view1.isShowingImageLoadingIndicator, true, "Expected loading indicator for the second view while loading second view")
        
        loader.completeImageLoading(at: 0)
        XCTAssertEqual(view0.isShowingImageLoadingIndicator, false, "Expected no indicator for the first view on image loading completion")
        XCTAssertEqual(view1.isShowingImageLoadingIndicator, true, "Expected loading indicator for the second view while loading second view")
        
        loader.completeImageLoadingWithError(at: 1)
        XCTAssertEqual(view0.isShowingImageLoadingIndicator, false, "Expected no indicator for the first view on image loading completion")
        XCTAssertEqual(view1.isShowingImageLoadingIndicator, false, "Expected no loading indicator for the second view on image loading completion with failure")
    }
    
    func test_feedImageView_rendersImageLoadedFromURL() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        sut.beginAppearanceTransition(true, animated: false)
        sut.endAppearanceTransition()
        loader.completeFeedLoading(with: [makeImage(), makeImage()])
        
        let view0 = sut.simulateFeedImageViewVisible(at: 0)
        let view1 = sut.simulateFeedImageViewVisible(at: 1)
        XCTAssertEqual(view0.renderedImage, .none, "Expected no image for the first view while loading first image")
        XCTAssertEqual(view1.renderedImage, .none, "Expected no image for the second view while loading second image")
        
        let imageData0 = UIImage.make(withColor: .red).pngData()!
        loader.completeImageLoading(with: imageData0, at: 0)
        XCTAssertEqual(view0.renderedImage, imageData0, "Expected image for the first view once first image loading completes successfully")
        XCTAssertEqual(view1.renderedImage, .none, "Expected no image state change for the second view once first image loading complets successfully")
        
        let imageData1 = UIImage.make(withColor: .blue).pngData()!
        loader.completeImageLoading(with: imageData1, at: 1)
        XCTAssertEqual(view0.renderedImage, imageData0, "Expected no image state change for first view once second image loading completes successfully")
        XCTAssertEqual(view1.renderedImage, imageData1, "Expected image for second view once second image loading completes successfully")
    }
    
    func test_feedImageViewRetryButton_isVisibleOnImageURLLoadError() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        sut.beginAppearanceTransition(true, animated: false)
        sut.endAppearanceTransition()
        loader.completeFeedLoading(with: [makeImage(), makeImage()])
        
        let view0 = sut.simulateFeedImageViewVisible(at: 0)
        let view1 = sut.simulateFeedImageViewVisible(at: 1)
        XCTAssertEqual(view0.isShowingRetryAction, false, "Expected no retry action visible while loading first image")
        XCTAssertEqual(view1.isShowingRetryAction, false, "Expected no retry action visible while loading second image")
        
        let imageData = UIImage.make(withColor: .red).pngData()!
        loader.completeImageLoading(with: imageData, at: 0)
        XCTAssertEqual(view0.isShowingRetryAction, false, "Expected no retry action for the first view once first image loading completes successfully")
        XCTAssertEqual(view1.isShowingRetryAction, false, "Expected no retry action state change for second view once first image loading completes successfully")
        
        loader.completeImageLoadingWithError(at: 1)
        XCTAssertEqual(view0.isShowingRetryAction, false, "Expected no retry action state change for the first view once second image loading completes with error")
        XCTAssertEqual(view1.isShowingRetryAction, true, "Expected retry action for second view once second image loading completes with error")
    }
    
    func test_feedImageViewRetryButton_isVisibleOnInvalidImageData() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        sut.beginAppearanceTransition(true, animated: false)
        sut.endAppearanceTransition()
        loader.completeFeedLoading(with: [makeImage()])

        let view = sut.simulateFeedImageViewVisible(at: 0)
        XCTAssertEqual(view.isShowingRetryAction, false, "Expected no retry action while loading image")

        let invalidImageData = Data("invalid image data".utf8)
        loader.completeImageLoading(with: invalidImageData, at: 0)
        XCTAssertEqual(view.isShowingRetryAction, true, "Expected retry action once image loading completes with invalid image data")
    }
    
    func test_feedImageViewRetryAction_retriesImageLoad() {
        let image0 = makeImage(url: URL(string: "http://url-0.com")!)
        let image1 = makeImage(url: URL(string: "http://url-1.com")!)
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        sut.beginAppearanceTransition(true, animated: false)
        sut.endAppearanceTransition()
        loader.completeFeedLoading(with: [image0, image1])

        let view0 = sut.simulateFeedImageViewVisible(at: 0)
        let view1 = sut.simulateFeedImageViewVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [image0.imageURL, image1.imageURL], "Expected two image URL request for the two visible views")

        loader.completeImageLoadingWithError(at: 0)
        loader.completeImageLoadingWithError(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [image0.imageURL, image1.imageURL], "Expected only two image URL requests before retry actionimageURL")
        view0.simulateRetryAction()
        XCTAssertEqual(loader.loadedImageURLs, [image0.imageURL, image1.imageURL, image0.imageURL], "Expected third imageURL request after first view retry action")

        view1.simulateRetryAction()
        XCTAssertEqual(loader.loadedImageURLs, [image0.imageURL, image1.imageURL, image0.imageURL, image1.imageURL], "Expected fourth imageURL request after second view retry action")
    }
    
    func test_feedImageView_preloadsImageURLWhenNearVisible() {
        let image0 = makeImage(url: URL(string: "http://url-0.com")!)
        let image1 = makeImage(url: URL(string: "http://url-1.com")!)
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        sut.beginAppearanceTransition(true, animated: false)
        sut.endAppearanceTransition()
        loader.completeFeedLoading(with: [image0, image1])
        XCTAssertEqual(loader.loadedImageURLs, [], "Expected no image URL requests until image is near visible")

        sut.simulateFeedImageViewNearVisible(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [image0.imageURL], "Expected first image URL request once first image is near visible")

        sut.simulateFeedImageViewNearVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [image0.imageURL, image1.imageURL], "Expected second image URL request once second image is near visible")
    }
    
    func test_feedImageView_cancelsImageURLPreloadingWhenNotNearVisibleAnymore() {
        let image0 = makeImage(url: URL(string: "http://url-0.com")!)
        let image1 = makeImage(url: URL(string: "http://url-1.com")!)
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        sut.beginAppearanceTransition(true, animated: false)
        sut.endAppearanceTransition()
        loader.completeFeedLoading(with: [image0, image1])
        XCTAssertEqual(loader.cancelledImageURLs, [], "Expected no cancelled image URL requests until image is not near visible")

        sut.simulateFeedImageViewNotNearVisible(at: 0)
        XCTAssertEqual(loader.cancelledImageURLs, [image0.imageURL], "Expected first cancelled image URL request once first image is not near visible anymore")

        sut.simulateFeedImageViewNotNearVisible(at: 1)
        XCTAssertEqual(loader.cancelledImageURLs, [image0.imageURL, image1.imageURL], "Expected second cancelled image URL request once second image is not near visible anymore")
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedViewController(feedLoader: loader, imageLoader: loader)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }
    
    private func makeImage(
        description: String? = nil,
        location: String? = nil,
        url: URL = URL(string: "https://any-url.com")!
    ) -> FeedImage {
        FeedImage(
            id: UUID(),
            description: description,
            location: location,
            imageURL: url
        )
    }
}
