//
//  RemoteFeedItem.swift
//  EssentialFeed
//
//  Created by Mukesh Nagi Reddy on 19/07/25.
//

import Foundation

struct RemoteFeedItem: Decodable {
  let id: UUID
  let description: String?
  let location: String?
  let image: URL
}
