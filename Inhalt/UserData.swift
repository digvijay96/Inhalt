//
//  UserData.swift
//  Inhalt
//
//  Created by digvijay.s on 13/09/17.
//  Copyright © 2017 digvijay.s. All rights reserved.
//

import UIKit
import CoreData

class UserData: NSManagedObject {
    static func findOrCreate(matching userInfo: User, in context: NSManagedObjectContext) throws -> UserData {
        let request: NSFetchRequest<UserData> = UserData.fetchRequest()
        request.predicate = NSPredicate(format: "screenName = %@", userInfo.screenName)
        do {
            let matches = try context.fetch(request)
            if matches.count > 0{
                return matches[0]
            }
            
        }
        catch {
            throw error
        }
        
        let twitterUser = UserData(context: context)
        twitterUser.screenName = userInfo.screenName
        twitterUser.name = userInfo.name
        twitterUser.identifier = userInfo.id
        twitterUser.profileImageUrl = userInfo.profileImageUrl.absoluteString
        twitterUser.descriptionData = userInfo.description
        twitterUser.following = userInfo.following
        twitterUser.followersCount = Int64(userInfo.followersCount)
        twitterUser.friendsCount = Int64(userInfo.friendsCount)
        return twitterUser
    }
    
    static func getAllFollowingUsers (in context: NSManagedObjectContext) throws -> [UserData] {
        let request: NSFetchRequest<UserData> = UserData.fetchRequest()
        request.predicate = NSPredicate(format: "following = %d", 1)
        do {
            let userData = try context.fetch(request)
            return userData
        }
        catch {
            throw error
        }
    }
}
