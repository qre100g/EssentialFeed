//
//  XCTestCase+FailableDeleteFeedStoreSpecs.swift
//  EssentialFeed
//
//  Created by Mukesh Nagi Reddy on 16/08/25.
//

import XCTest
import EssentialFeed

extension FailableDeleteFeedStoreSpecs where Self: XCTestCase {
    func assertThatDeleteDeliversErrorOnDeletionError(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        let deletionError = deleteCacheFeed(from: sut)
        
        XCTAssertNotNil(deletionError, "Expected cache deletion to fail with errror", file: file, line: line)
    }
    
    func assertThatDeleteHasNoSideEffectsOnDeletionError(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        deleteCacheFeed(from: sut)
        
        expect(sut, toRetrieve: .success(.none), file: file, line: line)
    }
}
