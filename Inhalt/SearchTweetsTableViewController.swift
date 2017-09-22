//
//  SearchTweetsTableViewController.swift
//  Inhalt
//
//  Created by digvijay.s on 31/08/17.
//  Copyright © 2017 digvijay.s. All rights reserved.
//

import UIKit
import CoreData

class SearchTweetsTableViewController: UITableViewController, UISearchBarDelegate, TweetTableViewCellProtocol {
    
    private var lastTwitterRequest: Request?
    private var refreshRequested: Bool = false
    private var request: Request?
    var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    private var tweets = [Tweet]()
    private var trends = [String]()
    var activityIndicatorView: UIActivityIndicatorView!
    
    private var searchTerm: String? {
        didSet{
            tweetSearchBar?.resignFirstResponder()
            trends = []
            tweets = []
            tableView.reloadData()
            tableView.separatorStyle = UITableViewCellSeparatorStyle.none
            activityIndicatorView.startAnimating()
            lastTwitterRequest = nil
            performSearchRequest()
        }
    }
    
    func editCellDataAfterFavorite(_ cell: Any, changeLikeCountTo favoriteCount: Int, changeFavouritedTo favorite: Bool) {
        let tweetTableViewCell: UITableViewCell
        if type(of: cell) == TweetTableViewCell.self {
            tweetTableViewCell = (cell as? TweetTableViewCell)!
        }
        else {
            tweetTableViewCell = (cell as? TweetWithMediaTableViewCell)!
        }
        let indexPath = tableView.indexPath(for: tweetTableViewCell)
        tweets[(indexPath?.row)!].favorited = favorite
        tweets[(indexPath?.row)!].favouriteCount = favoriteCount
        DispatchQueue.main.async { [weak self] in
            self?.tableView?.reloadRows(at: [indexPath!], with: .automatic)
            //            self?.tableView.reloadData()
        }
    }
    
    func editCellDataAfterRetweet(_ cell: Any, changeRetweetCountTo retweetCount: Int, changeRetweetedTo retweet: Bool) {
        let tweetTableViewCell: UITableViewCell
        if type(of: cell) == TweetTableViewCell.self {
            tweetTableViewCell = (cell as? TweetTableViewCell)!
        }
        else {
            tweetTableViewCell = (cell as? TweetWithMediaTableViewCell)!
        }
        let indexPath = tableView.indexPath(for: tweetTableViewCell)
        tweets[(indexPath?.row)!].retweeted = retweet
        tweets[(indexPath?.row)!].retweetCount = retweetCount
        DispatchQueue.main.async { [weak self] in
            self?.tableView?.reloadRows(at: [indexPath!], with: .automatic)
            //            self?.tableView.reloadData()
        }
    }
    
    private func showTweets(_ tweets: [Any]) {
        self.tweets = tweets as! [Tweet]
        tableView.separatorStyle = UITableViewCellSeparatorStyle.singleLine
        activityIndicatorView.stopAnimating()
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }

//        print(self.tweets)
    }
    
    private func showTrends(_ trends: [Any]) {
        self.trends = trends as! [String]
        let context = container?.viewContext
        let trendData = Trend.get(in: context!)
        for trend in trendData {
            context?.delete(trend)
        }
        do {
            try context?.save()
        } catch let error as NSError {
            print("Could not save \(error)")
        }
        container?.performBackgroundTask{ [weak self] context in
            for trend in (self?.trends)! {
                Trend.create(named: trend, in: context)
            }
            try? context.save()
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
        print(trends)
    }
    
    @IBAction func refreshControl(_ sender: Any) {
        refreshRequested = true
        performSearchRequest()
    }
    
    
    @IBOutlet weak var tweetSearchBar: UISearchBar!
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchTerm = searchBar.text
    }
    
    private func performSearchRequest() {
        let parameters: Dictionary<String, String> = ["q": searchTerm!, "count": "20"]
        request = lastTwitterRequest?.newer ?? Request("search", parameters)
        lastTwitterRequest = request
        request?.twitterGetRequest(before: showTweets)
        if(refreshRequested) {
            refreshControl?.endRefreshing()
        }
    }
    
    private func performTrendsRequest() {
        let parameters: Dictionary<String, String> = ["id": "1"]
        request = Request("trends", parameters)
        request?.twitterGetRequest(before: showTrends)
    }
    
    private func showTrendsFromDb() {
        let context = container?.viewContext
        let trendData = Trend.get(in: context!)
        for trend in trendData {
            trends.append(trend.title!)
        }
        tableView.reloadData()
    }
    
    private func showProfileImage() {
        let profileImageUrl = UserDefaults.standard.url(forKey: "userProfileImage")
        if profileImageUrl != nil {
            print("Inside profile image")
            let userProfileImage = UIButton.init(type: .custom)
            userProfileImage.sd_setImage(with: profileImageUrl!, for: .normal, completed: nil)
            userProfileImage.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            userProfileImage.layer.borderWidth = 1
            userProfileImage.layer.masksToBounds = false
            userProfileImage.layer.borderColor = UIColor.black.cgColor
            userProfileImage.layer.cornerRadius = userProfileImage.frame.height/2
            userProfileImage.clipsToBounds = true
            let leftBarButton = UIBarButtonItem(customView: userProfileImage)
            self.navigationItem.leftBarButtonItem = leftBarButton
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Search"
        if Reachability.isConnectedToNetwork() {
            performTrendsRequest()
        } else {
            showTrendsFromDb()
        }
        tableView.register(UINib(nibName: "TweetTableViewCell", bundle: nil), forCellReuseIdentifier: "tweetCell")
        tableView.register(UINib(nibName: "TweetWithMediaTableViewCell", bundle: nil), forCellReuseIdentifier: "tweetWithMediaCell")
        tweetSearchBar.delegate = self
        self.tabBarController?.title = "Search"
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        activityIndicatorView.center = tableView.center
        tableView.addSubview(activityIndicatorView)
        showProfileImage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if searchTerm == nil {
            return trends.count
        }
        else {
            return tweets.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if searchTerm == nil {
            let cell =  tableView.dequeueReusableCell(withIdentifier: "searchTrendCell", for: indexPath)
            let trend = trends[indexPath.row]
            if let searchTrendCell = cell as? SearchTrendTableViewCell {
                searchTrendCell.trend = trend
            }
            
            return cell
        }
        else {
            let tweet = tweets[indexPath.row]
            if tweet.media.isEmpty {
                let cell = tableView.dequeueReusableCell(withIdentifier: "tweetCell", for: indexPath) as! TweetTableViewCell
                cell.tweet = tweet
                cell.tweetDataDelegate = self
                return cell
            }
            else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "tweetWithMediaCell", for: indexPath) as! TweetWithMediaTableViewCell
                cell.tweet = tweet
                cell.tweetDataDelegate = self
                return cell
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if searchTerm == nil {
            searchTerm = trends[indexPath.row]
        }
    }

}
