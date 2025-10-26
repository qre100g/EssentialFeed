//
//  UIRefreshControl+TestHelpers.swift
//  EssentialFeed
//
//  Created by Mukesh Kondreddy on 26/10/25.
//

import UIKit

extension UIRefreshControl {
    func simulatePullToRefresh() {
        simulate(event: .valueChanged)
    }
}

