//
//  TweetTableTableViewController.swift
//  Inhalt
//
//  Created by digvijay.s on 29/08/17.
//  Copyright © 2017 digvijay.s. All rights reserved.
//

import UIKit
import CoreData

class TweetTableViewController: UITableViewController, TweetTableViewCellProtocol {
    
    private var request :Request?
    var tweets = [Tweet]()
    var tweetData: [TweetData] = []
    public var userID: String? = nil
    private var lastTwitterRequest: Request?
    private var refreshRequested: Bool = false
    var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    
    private func saveTweets(_ tweets: [Any]) {
//        if tweets.isEmpty == false {
//            tweets.insert(<#T##newElement: Tweet##Tweet#>, at: <#T##Int#>)
//        }
        self.tweets = tweets as! [Tweet]
//        var oldTweets = try? TweetData.getAllTweets(in: (container?.viewContext)!)
        
        container?.performBackgroundTask{ [weak self] context in
            let oldTweets = try? TweetData.getAllTweets(in: context)
            for tweet in oldTweets! {
                print(tweet)
                if Date().timeIntervalSince(tweet.created! as Date) > 24*60*60*2 {
                    context.delete(tweet)
                }
            }
            for tweetInfo in (self?.tweets)! {
                let tweet = try? TweetData.findOrCreateTweet(matching: tweetInfo, in: context)
                tweet?.setValue(tweetInfo.favorited, forKey: "favorited")
                tweet?.setValue(tweetInfo.favouriteCount, forKey: "favouriteCount")
                tweet?.setValue(tweetInfo.retweeted, forKey: "retweeted")
                tweet?.setValue(tweetInfo.retweetCount, forKey: "retweetCount")
//                print("This is tweety")
//                print(tweety ?? "tweety not found")
            }
            try? context.save()
            self?.printDatabaseStatistics()
        }
//        print(self.tweets)
    }
    
    private func printDatabaseStatistics() {
        if let context = container?.viewContext {
            context.perform{
                let request: NSFetchRequest<TweetData> = TweetData.fetchRequest()
                if let tweetCount = (try? context.fetch(request))?.count {
                    print ("\(tweetCount) tweets")
                }
                if let tweeterCount = try? context.count(for: UserData.fetchRequest()) {
                    print ("\(tweeterCount) Twitter Users")
                }
            }
        }
    }

    
//    private func saveTweets(_ tweets: [Any]) {
//        
//    }
    
    @IBAction func refreshControl(_ sender: UIRefreshControl) {
        refreshRequested = true
        if userID == nil {
            performRequest()
        }
        else {
            performUserTimelineRequest()
        }
    }
    
    func didPressLikeOrRetweetButton(_ changedTweet: [Any]) -> Void {
//        let changedTweet = changedTweet[0] as? Tweet
//        var index: Int?
//        print("changing tweet")
//        for indexValue in 0..<tweets.count {
//            if tweets[indexValue].identifier == changedTweet?.identifier {
//                tweets[indexValue] = changedTweet!
//                index = indexValue
//                break
//            }
//        }
////        let indexPath = IndexPath(item: index!, section: 0)
//        DispatchQueue.main.async { [weak self] in
////                self?.tableView?.reloadRows(at: [indexPath], with: .top)
//            self?.tableView.reloadData()
//        }
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
//        let tweetTableViewCell = cell as? TweetTableViewCell
        let indexPath = tableView.indexPath(for: tweetTableViewCell)
        tweets[(indexPath?.row)!].retweeted = retweet
        tweets[(indexPath?.row)!].retweetCount = retweetCount
        DispatchQueue.main.async { [weak self] in
            self?.tableView?.reloadRows(at: [indexPath!], with: .automatic)
//            self?.tableView.reloadData()
        }
    }
    
    private func performRequest() {
        let parameters: Dictionary<String, String> = ["count": "50"]
        request = lastTwitterRequest?.newer ?? Request("home", parameters)
        lastTwitterRequest = request
        request?.twitterGetRequest(before: saveTweets)
        if refreshRequested {
            refreshControl?.endRefreshing()
        }
    }
    
    private func performUserTimelineRequest() {
        let parameters: Dictionary<String, String> = ["user_id": userID!, "count": "50", "include_rts": "false"]
        request = lastTwitterRequest?.newer ?? Request("user_timeline", parameters)
        lastTwitterRequest = request
        request?.twitterGetRequest(before: saveTweets)
        if refreshRequested {
            refreshControl?.endRefreshing()
        }
    }
    
//    private func getTweetDataFromDb() {
//        container?.performBackgroundTask{ [weak self] context in
//            self?.tweetData = try! TweetData.getAllTweets(in: context)
//            if (self?.tweetData.count)! > 0 {
//                print(self?.tweetData[0].created ?? "")
//                print(self?.tweetData)
//                print("Added items to db")
//            }
//            else {
//                print("DB not persisting")
//            }
//            print(NSDate())
//            DispatchQueue.main.async {
//                self?.tableView.reloadData()
//            }
//            
//        }
//        print(self.tweetData[0].created - NSDate())
//        
//    }
    
    @objc private func reloadTweetData() {
        if userID == nil {
            self.tweetData = try! TweetData.getAllTweets(in: (container?.viewContext)!)
        }
        else {
            self.tweetData = try! TweetData.getTweetsFromAUser(matching: userID!, in: (container?.viewContext)!)
        }
        if (self.tweetData.count) > 0 {
//            print(self.tweetData)
            self.tweets = []
            for tweet in self.tweetData {
                self.tweets.append(Tweet(tweet))
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        else  {
            print("DB not persisting")
            if userID == nil {
                performRequest()
            }
            else {
                performUserTimelineRequest()
            }
        }
        print(NSDate())
//        self.tweets = DataToObjectConverter.convertTweetDataToTweet(self.tweetData)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lastTwitterRequest = nil
        tableView.register(UINib(nibName: "TweetTableViewCell", bundle: nil), forCellReuseIdentifier: "tweetCell")
        tableView.register(UINib(nibName: "TweetWithMediaTableViewCell", bundle: nil), forCellReuseIdentifier: "tweetWithMediaCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        NotificationCenter.default.addObserver(forName: .NSManagedObjectContextDidSave, object: nil, queue: nil, using: {
            [weak self]
            notification in
//            print(notification.userInfo)
            print(notification.userInfo?.description ?? "No description found")
            if let insertedObjects = notification.userInfo?[NSInsertedObjectsKey] as? Set<NSManagedObject> {
                print(insertedObjects)
                if !insertedObjects.isEmpty && insertedObjects[insertedObjects.index(insertedObjects.startIndex, offsetBy: 0)] is TweetData {
                    print("Type cast successful")
                    self?.reloadTweetData()
                }
            }
            
        })
//        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadTweetData(notification:)), name: .NSManagedObjectContextDidSave, object: nil)
        if userID == nil {
            self.navigationItem.title = "Home"
            performRequest()
            reloadTweetData()
    //        self.tabBarController?.navigationItem.hidesBackButton = true
//            hideBackButton()
//            performRequest()
//            getTweetDataFromDb()
        }
        else {
//            self.navigationItem.hidesBackButton = true
//            let newBackButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: self, action: #selector(TweetTableViewController.back(sender:)))
//            self.navigationItem.leftBarButtonItem = newBackButton
            performUserTimelineRequest()
            reloadTweetData()
//            performUserTimelineRequest()
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if userID == nil {
            self.tabBarController?.title = "Home"
        }
        else {
            self.navigationItem.title = "Tweets"
        }
//        self.navigationItem.hidesBackButton = true
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
        return tweets.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tweet = tweets[indexPath.row]
//        print(tweet.identifier ?? "tweet not found")
//        print(tweet.text ?? "text not found")
//        print(tweet.tweeter?.name ?? "tweeter name not found")
//        print(tweet)
//        let cell: UITableViewCell
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
            //            if let tweetCell = cell as? TweetWithMediaTableViewCell {
//                tweetCell.tweet = tweet
//            }
            return cell
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
