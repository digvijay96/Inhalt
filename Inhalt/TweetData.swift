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
    static func changedFavorite(_ tweet: Tweet, from tweetData: TweetData) -> Bool {
        return tweet.favorited != tweetData.favorited && tweet.favouriteCount != Int(tweetData.favouriteCount)
    }
    
    static func changedRetweet(_ tweet: Tweet, from tweetData: TweetData) -> Bool {
        return tweet.retweeted != tweetData.retweeted && tweet.retweetCount != Int(tweetData.retweetCount)
    }
    
    static func findOrCreate(matching tweetInfo: Tweet, in context: NSManagedObjectContext) throws -> TweetData {
        let request: NSFetchRequest<TweetData> = TweetData.fetchRequest()
        request.predicate = NSPredicate(format: "identifier = %@", tweetInfo.identifier)
        do {
            let match = try context.fetch(request)
            if match.count > 0 {
                let tweet = match[0]
                if changedFavorite(tweetInfo, from: tweet) {
                    tweet.favorited = tweetInfo.favorited
                    tweet.favouriteCount = Int64(tweetInfo.favouriteCount)
                }
                if changedRetweet(tweetInfo, from: tweet) {
                    tweet.retweeted = tweetInfo.retweeted
                    tweet.retweetCount = Int64(tweetInfo.retweetCount)
                }
                return tweet
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
        tweet.tweeter = try? UserData.findOrCreate(matching: tweetInfo.user, in: context)
        if !tweetInfo.media.isEmpty {
            tweet.mediaUrl = tweetInfo.media[0].url.absoluteString
        }
        else {
            tweet.mediaUrl = ""
        }
        return tweet
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
