//
//  MainTabBarViewController.swift
//  Inhalt
//
//  Created by digvijay.s on 19/09/17.
//  Copyright © 2017 digvijay.s. All rights reserved.
//

import UIKit

class MainTabBarViewController: UITabBarController {
    
    var request: Request?
    
    private func saveUserData(_ user: [User]) {
        let loggedInUser = user[0]
        let profileImageUrl = loggedInUser.profileImageUrl
//        let imageData = try? Data(contentsOf: profileImageUrl)
        UserDefaults.standard.set(profileImageUrl, forKey: "userProfileImage")
        UserDefaults.standard.set(loggedInUser.followersCount, forKey: "userFollowersCount")
        UserDefaults.standard.set(loggedInUser.friendsCount, forKey: "userFriendsCount")
        UserDefaults.standard.set(loggedInUser.id, forKey: "userID")
        UserDefaults.standard.set(loggedInUser.name, forKey: "userName")
//        UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: loggedInUser), forKey: "userDetails")
    }
    
    private func loggedInUserDetails() {
//        let userID = UserDefaults.standard.string(forKey: "userID")
//        if userID != nil {
        let parameters: Dictionary<String, String> = [:]
        request = Request(Request.RequestType.verify_credentials.rawValue, parameters)
        request?.performUsersRequest(handler: saveUserData)
//        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loggedInUserDetails()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
