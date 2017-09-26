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
    
    private func showUsers(_ following: [User]) {
        self.following = following
        print(self.following)
        if following.count != followingData.count {
            container?.performBackgroundTask{ [weak self] context in
                for userInfo in (self?.following)! {
                    _ = try? UserData.findOrCreate(matching: userInfo, in: context)
                }
                try? context.save()
                //            self?.printDatabaseStatistics()
            }
        }
    }
    
    private func performRequest(){
        let parameters: Dictionary<String, String> = ["skip_status": "true"]
        request = Request("following", parameters)
        request?.performUsersRequest(handler: showUsers)
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
    
    private func showProfileImage() {
        let profileImageUrl = UserDefaults.standard.url(forKey: "userProfileImage")
        if profileImageUrl != nil {
            print("Inside profile image")
            let userProfileImage = UIButton.init(type: .custom)
            //        let imageData = try? Data(contentsOf: profileImageUrl)
            //            userProfileImage.setImage(UIImage(data: imageData!), for: .normal)
            userProfileImage.sd_setImage(with: profileImageUrl!, for: .normal, completed: nil)
            //        userProfileImage.addTarget(self, action: nil, for: UIControlEvents.touchUpInside)
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
        self.title = "Following"
        tableView.register(UINib(nibName: "FollowingTableViewCell", bundle: nil), forCellReuseIdentifier: "userCell")
        tableView.delegate = self
        tableView.dataSource = self
//        self.tabBarController?.navigationItem.title = "Following"
        self.tabBarController?.title = "Following"
        tableView.estimatedRowHeight = 90
        tableView.rowHeight = UITableViewAutomaticDimension
        showProfileImage()
        NotificationCenter.default.addObserver(forName: .NSManagedObjectContextDidSave, object: nil, queue: nil, using: {[weak self] notification in
            self?.reloadFollowingData()
            }
        )
        reloadFollowingData()
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showUserData", sender: indexPath)
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let destinationViewController = segue.destination
        if let profileViewController = destinationViewController as? ProfileViewController {
            let indexPath = sender as? IndexPath
            profileViewController.userDetails = following[(indexPath?.row)!]
        }
    }
 

}
