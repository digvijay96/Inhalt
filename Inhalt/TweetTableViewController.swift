//
//  TweetTableTableViewController.swift
//  Inhalt
//
//  Created by digvijay.s on 29/08/17.
//  Copyright © 2017 digvijay.s. All rights reserved.
//

import UIKit
import CoreData

class TweetTableViewController: FetchedResultsTableViewController, TweetTableViewCellProtocol {
    
    private var request :Request?
    var tweets = [Tweet]()
    var tweetData: [TweetData] = []
    public var userID: String? = nil
    private var lastTwitterRequest: Request?
    private var refreshRequested: Bool = false
    var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    var writingContext: NSManagedObjectContext?
    var fetchedResultsController: NSFetchedResultsController<TweetData>?
    
    private func saveTweets(_ tweets: [Tweet]) {
        if refreshRequested {
            refreshControl?.endRefreshing()
        }
        
        self.tweets = tweets
        writingContext?.perform { [weak self] in
                for tweetInfo in (self?.tweets)! {
                    _ = try? TweetData.findOrCreate(matching: tweetInfo, in: (self?.writingContext!)!)
                }
                try? self?.writingContext?.save()
            }
//                self.printDatabaseStatistics()
    }
    
    private func timelineIsForUser() -> Bool {
        if userID == nil {
            return false
        }
        else {
            return true
        }
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

    
    @IBAction func refreshControl(_ sender: UIRefreshControl) {
        refreshRequested = true
        if timelineIsForUser() {
            performUserTimelineRequest()
        }
        else {
            performRequest()
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
        let changedTweet = fetchedResultsController?.object(at: indexPath!)
        writingContext?.perform { [weak self] in
            let tweet = try? TweetData.findOrCreate(matching: Tweet(changedTweet!), in: (self?.writingContext!)!)
            tweet?.favorited = favorite
            tweet?.favouriteCount = Int64(favoriteCount)
            print(self?
                .fetchedResultsController?.delegate ?? "Not found")
            try? self?.writingContext?.save()
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
        let changedTweet = fetchedResultsController?.object(at: indexPath!)
        
        writingContext?.perform { [weak self] in
            let tweet = try? TweetData.findOrCreate(matching: Tweet(changedTweet!), in: (self?.writingContext!)!)
            tweet?.retweeted = retweet
            tweet?.retweetCount = Int64(retweetCount)
            try? self?.writingContext?.save()
        }
    }
    
    private func performRequest() {
        let parameters: Dictionary<String, String> = ["count": "50"]
        request = lastTwitterRequest?.newer ?? Request(Request.RequestType.home.rawValue, parameters)
        lastTwitterRequest = request
        request?.performTweetsGetRequest(handler: saveTweets)
    }
    
    private func performUserTimelineRequest() {
        let parameters: Dictionary<String, String> = ["user_id": userID!, "count": "50", "include_rts": "false"]
        request = lastTwitterRequest?.newer ?? Request(Request.RequestType.user_timeline.rawValue, parameters)
        lastTwitterRequest = request
        request?.performTweetsGetRequest(handler: saveTweets)
    }
    
    @objc private func createNewTweet() {
        performSegue(withIdentifier: "newTweet", sender: self)
//        let newTweetViewController = storyboard?.instantiateViewController(withIdentifier: "newTweetPopup") as! NewTweetViewController
//        let navController = UINavigationController(rootViewController: newTweetViewController)
//        present(navController, animated: true, completion: nil)
    }
    
    private func setTitleAndFetchedResultsController() {
        if timelineIsForUser() {
//            self.navigationItem.hidesBackButton = true
            let request: NSFetchRequest<TweetData> = TweetData.fetchRequest()
            request.predicate = NSPredicate(format: "tweeter.identifier = %@", userID!)
            let sortDescriptor = [NSSortDescriptor(key: "created", ascending: false)]
            request.sortDescriptors = sortDescriptor
            fetchedResultsController = NSFetchedResultsController<TweetData>(
                fetchRequest: request,
                managedObjectContext: (container?.viewContext)!,
                sectionNameKeyPath: nil,
                cacheName: nil
            )
            try? fetchedResultsController?.performFetch()
            print("fetchedController set")
            performUserTimelineRequest()
        }
        else {
            let request: NSFetchRequest<TweetData> = TweetData.fetchRequest()
            let sortDescriptor = [NSSortDescriptor(key: "created", ascending: false)]
            request.sortDescriptors = sortDescriptor
            fetchedResultsController = NSFetchedResultsController<TweetData>(
                fetchRequest: request,
                managedObjectContext: (container?.viewContext)!,
                sectionNameKeyPath: nil,
                cacheName: nil
            )
            print("fetchedController set")
            try? fetchedResultsController?.performFetch()
            performRequest()
        }

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
        writingContext = (UIApplication.shared.delegate as? AppDelegate)?.writeContext
        
        NotificationCenter.default.addObserver(forName: .NSManagedObjectContextDidSave, object: nil, queue: nil, using: {
            [weak self]
            notification in
            if let strongSelf = self {
                strongSelf.container?.viewContext.mergeChanges(fromContextDidSave: notification)
            }
            
//            print(notification.userInfo?.description ?? "No description found")
//            if let insertedObjects = notification.userInfo?[NSInsertedObjectsKey] as? Set<NSManagedObject> {
//                print(insertedObjects)
//                if !insertedObjects.isEmpty && insertedObjects[insertedObjects.index(insertedObjects.startIndex, offsetBy: 0)] is TweetData {
//                    print("Type cast successful")
//                    self?.reloadTweetData()
//                }
//            }
        
        })
        setTitleAndFetchedResultsController()
        fetchedResultsController?.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return fetchedResultsController?.sections?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
//        print(fetchedResultsController?.sections?.count ?? "")
        if let sections = fetchedResultsController?.sections, sections.count > 0 {
            return sections[section].numberOfObjects
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tweetData = fetchedResultsController?.object(at: indexPath)
        let tweet = Tweet(tweetData!)
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

}
