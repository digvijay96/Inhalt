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
    var loggedInUserID: String?
    @IBOutlet weak var tweetsContainerView: UIView!
    
    private func setProfileImage() {
        profileImageView.layer.borderWidth = 1
        profileImageView.layer.masksToBounds = false
        profileImageView.layer.borderColor = UIColor.black.cgColor
        profileImageView.layer.cornerRadius = profileImageView.frame.height/2
        profileImageView.clipsToBounds = true
        let profileImageUrl = UserDefaults.standard.url(forKey: "userProfileImage")
        loggedInUserID = UserDefaults.standard.string(forKey: "userID")
        let profileImageUrlString = profileImageUrl?.absoluteString
        let biggerProfileImageUrl = URL(string: (profileImageUrlString?.replacingOccurrences(of: "normal", with: "bigger"))!)
        profileImageView.sd_setImage(with: biggerProfileImageUrl, placeholderImage: nil)
        view.bringSubview(toFront: profileImageView)
    }
    
    private func showUserTweetsInContainerView() {
        let userTweetTableViewController = self.storyboard?.instantiateViewController(withIdentifier: "tweetTableViewController") as! TweetTableViewController
        userTweetTableViewController.userID = loggedInUserID
        userTweetTableViewController.view.frame = tweetsContainerView.bounds
        tweetsContainerView.layer.borderWidth = 1
        tweetsContainerView.layer.borderColor = UIColor.black.cgColor
        tweetsContainerView.addSubview(userTweetTableViewController.view)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setProfileImage()
        showUserTweetsInContainerView()
//        addChildViewController(news)
//        news.didMove(toParentViewController: self)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
