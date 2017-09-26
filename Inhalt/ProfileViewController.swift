//
//  ProfileViewController.swift
//  Inhalt
//
//  Created by digvijay.s on 20/09/17.
//  Copyright © 2017 digvijay.s. All rights reserved.
//

import UIKit
import CoreData

class ProfileViewController: UIViewController, UITableViewDelegate {
    @IBOutlet weak var profileImageView: UIImageView!
    var userID: String?
    var userDetails: User?
    @IBOutlet weak var tweetsContainerView: UIView!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    
    private func setUserDetails() {
        profileImageView.layer.borderWidth = 1
        profileImageView.layer.masksToBounds = false
        profileImageView.layer.borderColor = UIColor.black.cgColor
        profileImageView.layer.cornerRadius = profileImageView.frame.height/2
        profileImageView.clipsToBounds = true
        let profileImageUrl: URL?
        let followersCount: Int?
        let followingCount: Int?
        let userName: String?
        if userDetails == nil {
//            if let userObject = UserDefaults.standard.value(forKey: "userDetails") {
//                userDetails = NSKeyedUnarchiver.unarchiveObject(with: userObject as! Data) as? User
//            }
            profileImageUrl = UserDefaults.standard.url(forKey: "userProfileImage")
            userID = UserDefaults.standard.string(forKey: "userID")
            followersCount = UserDefaults.standard.integer(forKey: "userFollowersCount")
            followingCount = UserDefaults.standard.integer(forKey: "userFriendsCount")
            userName = UserDefaults.standard.string(forKey: "userName")
//            userDetails = UserDefaults.standard.object(forKey: "userDetails") as? User
        }
        else {
            profileImageUrl = (userDetails?.profileImageUrl)
            userID = userDetails?.id
            followingCount = userDetails?.friendsCount
            followersCount = userDetails?.followersCount
            userName = userDetails?.name
        }
        if (followingCount)! > 1000 {
            followingLabel.text = "\(followingCount!/1000)k following"
        }else {
            followingLabel.text = "\(followingCount ?? 0) following"
        }
        if (followersCount)! > 1000 {
            followersLabel.text = "\(followersCount!/1000)k followers"
        }
        else {
            followersLabel.text = "\(followersCount ?? 0) followers"
        }
        userNameLabel.text = userName
        let profileImageUrlString = profileImageUrl?.absoluteString
        let biggerProfileImageUrl = URL(string: (profileImageUrlString?.replacingOccurrences(of: "normal", with: "bigger"))!)
        profileImageView.sd_setImage(with: biggerProfileImageUrl, placeholderImage: nil)
        
        view.bringSubview(toFront: profileImageView)
    }
    
    private func showUserTweetsInContainerView() {
        let userTweetTableViewController = self.storyboard?.instantiateViewController(withIdentifier: "tweetTableViewController") as! TweetTableViewController
        userTweetTableViewController.userID = userID
        userTweetTableViewController.view.frame = tweetsContainerView.bounds
        tweetsContainerView.layer.borderWidth = 1
        tweetsContainerView.layer.borderColor = UIColor.black.cgColor
        tweetsContainerView.addSubview(userTweetTableViewController.view)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUserDetails()
        showUserTweetsInContainerView()
//        addChildViewController(news)
//        news.didMove(toParentViewController: self)
        // Do any additional setup after loading the view.
    }

}
