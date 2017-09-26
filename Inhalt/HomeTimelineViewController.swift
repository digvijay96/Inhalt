//
//  HomeTimelineViewController.swift
//  Inhalt
//
//  Created by digvijay.s on 26/09/17.
//  Copyright © 2017 digvijay.s. All rights reserved.
//

import UIKit

class HomeTimelineViewController: UIViewController {

    @IBOutlet weak var tweetsContainerView: UIView!
    
    private func showProfileImage() {
        let profileImageUrl = UserDefaults.standard.url(forKey: "userProfileImage")
        if profileImageUrl != nil {
            print("Inside profile image")
            let userProfileImage = UIButton.init(type: .custom)
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
    
    @objc private func createNewTweet() {
        performSegue(withIdentifier: "newTweet", sender: self)

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Home"
        showProfileImage()
        let newTweetButton = UIButton.init(type: .custom)
        newTweetButton.setImage(UIImage(named: "tweetButton"), for: .normal)
        newTweetButton.addTarget(self, action: #selector(createNewTweet), for: UIControlEvents.touchUpInside)
        newTweetButton.frame = CGRect(x: 0, y: 0, width: 28, height: 24)
        let barButton = UIBarButtonItem(customView: newTweetButton)
        self.navigationItem.rightBarButtonItem = barButton
        let userTweetTableViewController = self.storyboard?.instantiateViewController(withIdentifier: "tweetTableViewController") as! TweetTableViewController
        userTweetTableViewController.view.frame = tweetsContainerView.bounds
        tweetsContainerView.layer.borderWidth = 1
        tweetsContainerView.layer.borderColor = UIColor.black.cgColor
        tweetsContainerView.addSubview(userTweetTableViewController.view)
        // Do any additional setup after loading the view.
    }


}
