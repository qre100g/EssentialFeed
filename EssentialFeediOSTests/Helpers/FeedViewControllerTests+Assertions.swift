//
//  FeedViewControllerTests+Assertions.swift
//  EssentialFeed
//
//  Created by Mukesh Kondreddy on 26/10/25.
//

import XCTest
import EssentialFeed
import EssentialFeediOS

extension FeedViewControllerTests {
    
    func assertThat(
        _ sut: FeedViewController,
        isRenderingWith feed: [FeedImage],
        file: StaticString = #file,
        line: UInt = #line
    ) {
        guard sut.numberOfRenderedFeedImageViews() == feed.count else {
            return XCTFail("Expected visible cell count is \(feed.count) got \(sut.numberOfRenderedFeedImageViews()) instead", file: file, line: line)
        }
        
        feed.enumerated().forEach { index, image in
            assertThat(sut, hasViewConfiguredWith: image, at: index, file: file, line: line)
        }
    }
    
    func assertThat(
        _ sut: FeedViewController,
        hasViewConfiguredWith image: FeedImage,
        at index: Int,
        file: StaticString,
        line: UInt
    ) {
        let view = sut.feedImageView(at: index)
        
        guard let cell = view as? FeedImageCell else {
            return XCTFail("Expected \(FeedImageCell.self) instance got \(String(describing: view)) instead", file: file, line: line)
        }
        
        let shouldLocationBeVisible = image.location != nil
        XCTAssertEqual(cell.isLocationVisible, shouldLocationBeVisible)
        XCTAssertEqual(cell.locationText, image.location)
        XCTAssertEqual(cell.descriptionText, image.description)
    }

}
