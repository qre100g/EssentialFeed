//
//  XCTTestCase+FailableInsertFeedStoreSpecs.swift
//  EssentialFeed
//
//  Created by Mukesh Nagi Reddy on 16/08/25.
//
import XCTest
import EssentialFeed

extension FailableInsertFeedStoreSpecs where Self: XCTestCase {
    func assertThatInsertDeliversErrorOnInsertionError(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        let insertonError = insert((uniqueFeedItems().local, Date()), to: sut)
        
        XCTAssertNotNil(insertonError, "Expected cache insetion to fail with errror", file: file, line: line)
    }
    
    func assertThatInsertHasNoSideEffectsOnInsertionError(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        insert((uniqueFeedItems().local, Date()), to: sut)
        
        expect(sut, toRetrieve: .success(.none), file: file, line: line)
    }
}
