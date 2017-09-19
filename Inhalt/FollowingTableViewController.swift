//
//  FollowingTableViewController.swift
//  Inhalt
//
//  Created by digvijay.s on 06/09/17.
//  Copyright © 2017 digvijay.s. All rights reserved.
//

import UIKit
import CoreData

class FollowingTableViewController: UITableViewController {
    
    private var request :Request?
    private var following = [User]()
    private var followingData = [UserData]()
    var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    
    private func showUsers(_ following: [Any]) {
        self.following = following as! [User]
        container?.performBackgroundTask{ [weak self] context in
            for userInfo in (self?.following)! {
                _ = try? UserData.findOrCreate(matching: userInfo, in: context)
                //                print("This is tweety")
                //                print(tweety ?? "tweety not found")
            }
            try? context.save()
            //            self?.printDatabaseStatistics()
        }
    }
    
    private func performRequest(){
        let parameters: Dictionary<String, String> = ["skip_status": "true"]
        request = Request("following", parameters)
        request?.twitterGetRequest(before: showUsers)
    }
    
    func reloadFollowingData() {
        self.followingData = try! UserData.getAllFollowingUsers(in: (container?.viewContext)!)
        if (self.followingData.count) > 0 {
            //            print(self.tweetData)
            self.following = []
            for followingUser in self.followingData {
                self.following.append(User(followingUser))
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        else  {
            performRequest()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "FollowingTableViewCell", bundle: nil), forCellReuseIdentifier: "userCell")
        tableView.delegate = self
        tableView.dataSource = self
//        self.tabBarController?.navigationItem.title = "Following"
        self.tabBarController?.title = "Following"
        tableView.estimatedRowHeight = 90
        tableView.rowHeight = UITableViewAutomaticDimension
        NotificationCenter.default.addObserver(forName: .NSManagedObjectContextDidSave, object: nil, queue: nil, using: {[weak self] notification in
            self?.reloadFollowingData()
            }
        )
        reloadFollowingData()
//        tableView.rowHeight = 90
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "Following"
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
        return following.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let followingUser = following[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! FollowingTableViewCell

        // Configure the cell...
        cell.tweeterNameLabel?.text = followingUser.name
        cell.tweeterHandleLabel?.text = followingUser.screenName
        cell.tweeterDescriptionLabel?.text = followingUser.description
        cell.profileImageView?.image = nil
        let profileImageUrl = followingUser.profileImageUrl
        cell.profileImageView.sd_setImage(with: profileImageUrl, placeholderImage: nil)
        
//        DispatchQueue.global(qos: .userInitiated).async {
//            let profileImageUrl = followingUser.profileImageUrl
//            if let imageData = try? Data(contentsOf: profileImageUrl) {
//                DispatchQueue.main.async {
//                    if id == followingUser.id {
//                        cell.profileImageView?.image = UIImage(data: imageData)
//                    }
//                }
//            }
//        }

        return cell
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showUserTweets", sender: indexPath)
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let destinationViewController = segue.destination
        if let tweetTableViewController = destinationViewController as? TweetTableViewController {
            let indexPath = sender as? IndexPath
            tweetTableViewController.userID = following[(indexPath?.row)!].id
        }
    }
 

}
