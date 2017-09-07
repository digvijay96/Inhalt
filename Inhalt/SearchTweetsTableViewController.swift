//
//  SearchTweetsTableViewController.swift
//  Inhalt
//
//  Created by digvijay.s on 31/08/17.
//  Copyright © 2017 digvijay.s. All rights reserved.
//

import UIKit

class SearchTweetsTableViewController: UITableViewController, UISearchBarDelegate {
    
    private var lastTwitterRequest: Request?
    private var refreshRequested: Bool = false
    private var request: Request?
    private var tweets = [Tweet]()

    private var searchTerm: String? {
        didSet{
            tweetSearchBar?.resignFirstResponder()
            lastTwitterRequest = nil
            performSearchRequest()
        }
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
    
    private func showTweets(_ tweets: [Any]) {
        self.tweets = tweets as! [Tweet]
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
        print(self.tweets)
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "TweetTableViewCell", bundle: nil), forCellReuseIdentifier: "tweetCell")
        tableView.register(UINib(nibName: "TweetWithMediaTableViewCell", bundle: nil), forCellReuseIdentifier: "tweetWithMediaCell")
        tweetSearchBar.delegate = self
        self.tabBarController?.title = "Search"
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        //searchTerm = "#hello"
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.title = "Search"
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
        if tweet.media.isEmpty {
            let cell = tableView.dequeueReusableCell(withIdentifier: "tweetCell", for: indexPath) as! TweetTableViewCell
            cell.tweeterNameLabel?.text = tweet.user.name
            cell.tweeterHandleLabel?.text = "@" + (tweet.user.screenName)
            cell.tweetTextLabel?.text = tweet.text
            cell.profileImageView.image = nil
            let id = tweet.identifier
            DispatchQueue.global(qos: .userInteractive).async {
                let profileImageUrl = tweet.user.profileImageUrl
                if let imageData = try? Data(contentsOf: profileImageUrl) {
                    DispatchQueue.main.async {
                        if id == tweet.identifier {
                            cell.profileImageView?.image = UIImage(data: imageData)
                        }
                    }
                }
            }
            
            let created = tweet.created
            let formatter = DateFormatter()
            if Date().timeIntervalSince(created) > 24*60*60 {
                formatter.dateStyle = .short
            } else {
                formatter.timeStyle = .short
            }
            cell.createdLabel?.text = formatter.string(from: created)
            
            return cell
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "tweetWithMediaCell", for: indexPath) as! TweetWithMediaTableViewCell
            cell.tweeterNameLabel?.text = tweet.user.name
            cell.tweeterHandleLabel?.text = "@" + (tweet.user.screenName)
            cell.tweetTextLabel?.text = tweet.text
            cell.profileImageView.image = nil
            let id = tweet.identifier
            DispatchQueue.global(qos: .userInteractive).async {
                let profileImageUrl = tweet.user.profileImageUrl
                if let imageData = try? Data(contentsOf: profileImageUrl) {
                    DispatchQueue.main.async {
                        if id == tweet.identifier {
                            cell.profileImageView?.image = UIImage(data: imageData)
                        }
                    }
                }
            }
            
            let created = tweet.created
            let formatter = DateFormatter()
            if Date().timeIntervalSince(created) > 24*60*60 {
                formatter.dateStyle = .short
            } else {
                formatter.timeStyle = .short
            }
            cell.tweetImageView?.image = UIImage(named: "blue22")
            cell.createdLabel?.text = formatter.string(from: created)
            DispatchQueue.global(qos: .userInteractive).async {
                let imageMediaUrl = tweet.media[0].url
                if let imageData = try? Data(contentsOf: imageMediaUrl) {
                    DispatchQueue.main.async {
                        if id == tweet.identifier {
                            cell.tweetImageView?.image = UIImage(data: imageData)
                        }
                    }
                }
            }

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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
//    }
 

}
