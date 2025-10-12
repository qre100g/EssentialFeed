//
//  File.swift
//  EssentialFeedTests
//
//  Created by Mukesh Nagi Reddy on 15/06/25.
//

import XCTest

extension XCTestCase {
    func trackForMemoryLeaks(_ object: AnyObject?, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak object] in
            XCTAssertNil(object, "Memory leak detected", file: file, line: line)
        }
    }
}
