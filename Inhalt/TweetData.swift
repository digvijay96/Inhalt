//
//  TweetData.swift
//  Inhalt
//
//  Created by digvijay.s on 13/09/17.
//  Copyright © 2017 digvijay.s. All rights reserved.
//

import UIKit
import CoreData

class TweetData: NSManagedObject {
    static func findOrCreateTweet(matching tweetInfo: Tweet, in context: NSManagedObjectContext) throws -> TweetData {
        let request: NSFetchRequest<TweetData> = TweetData.fetchRequest()
        request.predicate = NSPredicate(format: "identifier = %@", tweetInfo.identifier)
        do {
            let match = try context.fetch(request)
            if match.count > 0 {
                return match[0]
            }
        }
        catch {
            throw error
        }
        
        let tweet = TweetData(context: context)
        tweet.identifier = tweetInfo.identifier
        tweet.text = tweetInfo.text
        tweet.created = tweetInfo.created as NSDate
        tweet.favorited = tweetInfo.favorited
        tweet.favouriteCount = Int64(tweetInfo.favouriteCount)
        tweet.retweeted = tweetInfo.retweeted
        tweet.retweetCount = Int64(tweetInfo.retweetCount)
        tweet.tweeter = try? UserData.findOrCreateTwitterUser(matching: tweetInfo.user, in: context)
        if !tweetInfo.media.isEmpty {
            tweet.mediaUrl = tweetInfo.media[0].url.absoluteString
        }
        else {
            tweet.mediaUrl = ""
        }
        return tweet
    }
    
    static func getAllTweets(in context: NSManagedObjectContext) throws -> [TweetData] {
        let request: NSFetchRequest<TweetData> = TweetData.fetchRequest()
        let sortDescriptor = [NSSortDescriptor(key: "created", ascending: false)]
        request.sortDescriptors = sortDescriptor
        do {
            let tweetData = try context.fetch(request)
            return tweetData
        }
        catch {
            throw error
        }
    }
    
    static func getTweetsFromAUser(matching userId: String, in context: NSManagedObjectContext) throws -> [TweetData] {
        let request: NSFetchRequest<TweetData> = TweetData.fetchRequest()
        let sortDescriptor = [NSSortDescriptor(key: "created", ascending: false)]
        request.predicate = NSPredicate(format: "tweeter.identifier = %@", userId)
        request.sortDescriptors = sortDescriptor
        do {
            let matches = try context.fetch(request)
            return matches
        }
        catch {
            throw error
        }
    }
    
//    static func deleteOldTweets(in context: NSManagedObjectContext) throws {
//        let request: NSFetchRequest<TweetData> = TweetData.fetchRequest()
//        let sortDescriptor = [NSSortDescriptor(key: "created", ascending: false)]
//        request.sortDescriptors = sortDescriptor
//        do {
//            let tweetData = try context.fetch(request)
////            if Date().timeIntervalSince(tweetData.da)
//        }
//        
//    }
}
