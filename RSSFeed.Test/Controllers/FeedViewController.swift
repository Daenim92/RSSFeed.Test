//
//  ViewController.swift
//  RSSFeed.Test
//
//  Created by Daenim on 1/13/19.
//  Copyright © 2019 Daenim. All rights reserved.
//

import UIKit
import FeedKit
import WebKit
import SVProgressHUD

class FeedViewController: UIViewController {
    
    @IBOutlet weak var rssFeedTableView: UITableView?
    @IBOutlet weak var webView: WKWebView?
    var refreshControl: UIRefreshControl = {
        let r = UIRefreshControl()
        r.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return r
    }()

    var feedModel: [RSSFeedItem] = [] {
        didSet {
            rssFeedTableView?.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rssFeedTableView?.refreshControl = self.refreshControl
        webView?.navigationDelegate = self
        refresh()
    }
    
    @objc func refresh() {
        FeedConnection.shared.getFeed { (r) in
            DispatchQueue.main.async {
                self.feedModel = r.rssFeed?.items ?? []
                if let e = r.error {
                    SVProgressHUD.showError(withStatus: e.localizedDescription)
                    SVProgressHUD.dismiss(withDelay: 2.0)
                }
                self.refreshControl.endRefreshing()
            }
        }
    }

}

class FeedCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!
}

extension FeedViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feedModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "feedcell", for: indexPath)
        let model = feedModel[indexPath.row]
        
        (cell as? FeedCell).map {
            $0.titleLabel.text = model.title
            $0.detailsLabel.text = model.description ?? model.link
        }
        
        return cell
    }
}

extension FeedViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let link = feedModel[indexPath.row].link
            else { return }
        
        guard let url = URL(string: link)
            else { return }
        
        webView?.load(URLRequest(url: url))
    }
}

extension FeedViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        SVProgressHUD.show()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        SVProgressHUD.dismiss()
        self.webView?.isHidden = false
    }
}
