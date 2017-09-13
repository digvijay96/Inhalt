//
//  Tweet.swift
//  Inhalt
//
//  Created by digvijay.s on 31/08/17.
//  Copyright © 2017 digvijay.s. All rights reserved.
//

import Foundation

public struct Tweet {
    public let text: String
    public let user: User
    public let created: Date
    public let identifier: String
    public let media: [MediaItem]
    public var favorited: Bool
    public var retweeted: Bool
    public var favouriteCount: Int
    public var retweetCount: Int
    
    
    init?(data: NSDictionary?)
    {
        guard
            let user = User(data: data?.value(forKeyPath: TwitterKey.user) as? NSDictionary),
            let text = data?.value(forKeyPath: TwitterKey.text) as? String,
            //let text = data?.string(forKeyPath: TwitterKey.text),
            let created = twitterDateFormatter.date(from: data?.value(forKeyPath: TwitterKey.created) as? String ?? ""),
            let identifier = data?.value(forKeyPath: TwitterKey.identifier) as? String,
            let favorited = data?.value(forKeyPath: TwitterKey.favorited) as? Bool,
            let retweeted = data?.value(forKeyPath: TwitterKey.retweeted) as? Bool,
            let favouriteCount = data?.value(forKeyPath: TwitterKey.favourites) as?Int,
            let retweetCount = data?.value(forKeyPath: TwitterKey.retweets) as? Int
            else {
                return nil
            }
        
        self.user = user
        self.text = text
        self.created = created
        self.identifier = identifier
        self.favorited = favorited
        self.retweeted = retweeted
        self.favouriteCount = favouriteCount
        self.retweetCount = retweetCount
        self.media = Tweet.mediaItems(from: data?.value(forKeyPath: TwitterKey.media) as? NSArray)
    }
    
    private static func mediaItems(from twitterData: NSArray?) -> [MediaItem]{
        var mediaItems = [MediaItem]()
        for mediaItemData in twitterData ?? [] {
//            print(MediaItem(data: mediaItemData as? NSDictionary) ?? "Can't be converted")
//            print(mediaItemData as? NSDictionary ?? "Can't convert")
            if let mediaItem = MediaItem(data: mediaItemData as? NSDictionary){
                mediaItems.append(mediaItem)
            }
        }
        return mediaItems
    }

    struct TwitterKey {
        static let user = "user"
        static let text = "text"
        static let created = "created_at"
        static let identifier = "id_str"
        static let media = "entities.media"
        static let favorited = "favorited"
        static let retweeted = "retweeted"
        static let favourites = "favorite_count"
        static let retweets = "retweet_count"
    }
    
}

private let twitterDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "EEE MMM dd HH:mm:ss Z yyyy"
    formatter.locale = Locale(identifier: "en_US_POSIX")
    return formatter
}()
