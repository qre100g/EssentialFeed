//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Mukesh Nagi Reddy on 20/09/25.
//

import UIKit
import EssentialFeed

public class FeedViewController: UITableViewController {
    private var loader: FeedLoader?
    
    public convenience init(loader: FeedLoader) {
        self.init()
        
        self.loader = loader
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
    }
    
    public override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        
        load()
    }
    
    @objc func load() {
        refreshControl?.beginRefreshing()
        loader?.load() { [weak self] _ in
            self?.refreshControl?.endRefreshing()
        }
    }
}
