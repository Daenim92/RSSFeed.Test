//
//  FeedConnection.swift
//  RSSFeed.Test
//
//  Created by Daenim on 1/13/19.
//  Copyright © 2019 Daenim. All rights reserved.
//

import UIKit
import FeedKit

class FeedConnection: NSObject {
    fileprivate let url = URL(string:"https://wired.com/feed/rss")!
    
    static let shared = FeedConnection()
    
    fileprivate override init() {
        super.init()
    }

    func getFeed(_ listener: @escaping (FeedKit.Result) -> Void) {
        let parser = FeedParser(URL: self.url)
        parser.parseAsync { (result) in
            listener(result)
        }
    }
    
}
