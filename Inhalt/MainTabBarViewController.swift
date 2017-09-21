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
    
    private func saveUserData(_ user: [Any]) {
        let userData = user as! [User]
        let loggedInUser = userData[0]
        let profileImageUrl = loggedInUser.profileImageUrl
//        let imageData = try? Data(contentsOf: profileImageUrl)
        UserDefaults.standard.set(profileImageUrl, forKey: "userProfileImage")
        UserDefaults.standard.set(loggedInUser.id, forKey: "userID")
//        let userProfileImage = UIButton.init(type: .custom)
//        let imageData = try? Data(contentsOf: profileImageUrl)
//        userProfileImage.setImage(UIImage(data: imageData!), for: .normal)
////        userProfileImage.addTarget(self, action: nil, for: UIControlEvents.touchUpInside)
//        userProfileImage.frame = CGRect(x: 0, y: 0, width: 28, height: 24)
//        let barButton = UIBarButtonItem(customView: userProfileImage)
//        self.navigationItem.leftBarButtonItem = barButton
    }
    
    private func loggedInUserDetails() {
//        let userID = UserDefaults.standard.string(forKey: "userID")
//        if userID != nil {
        let parameters: Dictionary<String, String> = [:]
        request = Request("verify_credentials", parameters)
        request?.twitterGetRequest(before: saveUserData)
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
