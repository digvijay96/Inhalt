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
    
    func didPressLikeOrRetweetButton(_ changedTweet: [Any]) -> Void {
//        let changedTweet = changedTweet[0] as? Tweet
//        print("changing tweet")
//        var index: Int?
//        for indexValue in 0..<tweets.count {
//            if tweets[indexValue].identifier == changedTweet?.identifier {
//                tweets[indexValue] = changedTweet!
//                index = indexValue
//                break
//            }
//        }
////        let indexPath = IndexPath(item: index!, section: 0)
//        DispatchQueue.main.async { [weak self] in
//            self?.tableView.reloadData()
//        }
    }
    
//    @IBOutlet weak var searchTextField: UITextField! {
//        didSet{
//            searchTextField.delegate = self
//        }
//    }
//    
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        if textField == searchTextField {
//            print(searchTextField.text ?? "search field empty")
//            searchTerm = searchTextField.text
//        }
//        return true
//    }
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
//        tableView.backgroundView = activityIndicatorView
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
        //searchTerm = "#hello"
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "Search"
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
 

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation
    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
