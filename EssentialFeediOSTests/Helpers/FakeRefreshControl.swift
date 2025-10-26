//
//  FakeRefreshControl.swift
//  EssentialFeed
//
//  Created by Mukesh Kondreddy on 26/10/25.
//

import UIKit

class FakeRefreshControl: UIRefreshControl {
    private var _isRrefreshing: Bool = false
    
    override var isRefreshing: Bool { _isRrefreshing }
    
    override func beginRefreshing() {
        _isRrefreshing = true
    }
    
    override func endRefreshing() {
        _isRrefreshing = false
    }
}
