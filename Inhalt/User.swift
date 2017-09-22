//
//  User.swift
//  Inhalt
//
//  Created by digvijay.s on 31/08/17.
//  Copyright © 2017 digvijay.s. All rights reserved.
//

import Foundation

public struct User {
    public let screenName: String
    public let name: String
    public let id: String
    public let profileImageUrl: URL
    public let description: String
    public let following: Bool
    public let friendsCount: Int
    public let followersCount: Int
    
    init?(data: NSDictionary?) {
        guard
            let screenName = data?.value(forKeyPath: TwitterKey.screenName) as? String,
            let name = data?.value(forKeyPath: TwitterKey.name) as? String,
            let id = data?.value(forKeyPath: TwitterKey.identifier) as? String,
            let urlString = data?.value(forKeyPath: TwitterKey.profileImageURL) as? String,
            let description = data?.value(forKeyPath: TwitterKey.description) as? String,
            let following = data?.value(forKeyPath: TwitterKey.following) as? Bool,
            let friendsCount = data?.value(forKeyPath: TwitterKey.friendsCount) as? Int,
            let followersCount = data?.value(forKeyPath: TwitterKey.followersCount) as? Int
            else {
                return nil
            }
        
        self.screenName = screenName
        self.name = name
        self.id = id
        self.description = description
        let url = URL(string: urlString)
        self.profileImageUrl = url!
        self.following = following
        self.friendsCount = friendsCount
        self.followersCount = followersCount
    }
    
//    required init(coder decoder: NSCoder) {
//        self.name = decoder.decodeObject(forKey: "name") as? String ?? ""
//        self.age = decoder.decodeInteger(forKey: "age")
//    }
//    
//    func encode(with coder: NSCoder) {
//        coder.encode(name, forKey: "name")
//        coder.encode(age, forKey: "age")
//    }
    
    init(_ user: UserData) {
        self.screenName = user.screenName!
        self.name = user.name!
        self.id = user.identifier!
        self.description = user.descriptionData!
        let url = URL(string: user.profileImageUrl!)
        self.profileImageUrl = url!
        self.following = user.following
        self.followersCount = Int(user.followersCount)
        self.friendsCount = Int(user.friendsCount)
    }

    struct TwitterKey {
        static let name = "name"
        static let screenName = "screen_name"
        static let identifier = "id_str"
        static let verified = "verified"
        static let profileImageURL = "profile_image_url"
        static let description = "description"
        static let following = "following"
        static let friendsCount = "friends_count"
        static let followersCount = "followers_count"
    }
}
