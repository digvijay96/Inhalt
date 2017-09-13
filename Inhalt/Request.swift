//
//  Request.swift
//  
//
//  Created by digvijay.s on 29/08/17.
//
//

import Foundation
import Social
import Accounts
import Alamofire
import TwitterKit

public class Request : NSObject {
    
    public let requestType: String
    public let parameters: Dictionary<String, String>
    
    public init(_ requestType: String, _ parameters: Dictionary<String, String> = [:]){
        self.requestType = requestType
        self.parameters = parameters
    }
    
    private var max_id: String? = nil
    
    private func parseTweets (_ results: Any?) -> [Tweet] {
        var tweets = [Tweet]()
        var tweetArray: NSArray?
        if let dictionary = results as? NSDictionary {
            if let tweets = dictionary[TwitterKey.tweets] as? NSArray {
                tweetArray = tweets
            } else if let tweet = Tweet(data: dictionary) {
                tweets = [tweet]
            }
        } else if let array = results as? NSArray {
            tweetArray = array
        }
        if tweetArray != nil {
            for tweetData in tweetArray! {
                if let tweet = Tweet(data: tweetData as? NSDictionary) {
                    tweets.append(tweet)
                }
            }
        }
//        print(tweets)
        return tweets
    }
    
    private func parseUsers (_ results: Any?) -> [User] {
        var following = [User]()
        var userArray: NSArray?
        if let dictionary = results as? NSDictionary {
            if let following = dictionary[TwitterKey.users] as? NSArray {
                userArray = following
            } else if let user = User(data: dictionary) {
                following = [user]
            }
        }
        if userArray != nil {
            for userData in userArray! {
                if let user = User(data: userData as? NSDictionary) {
                    following.append(user)
                }
            }
        }
        print(following)
        return following
    }
    
    private func parseTrends(_ results: Any?) -> [String] {
        var trends = [String]()
        if let array = results as? NSArray {
            if let dictionary = array[0] as? NSDictionary {
                if let trendsArray = dictionary[TwitterKey.trends] as? NSArray {
                    for trend in trendsArray {
                        if let trendDictionary =  trend as? NSDictionary{
                            trends.append((trendDictionary[TwitterKey.name] as? String)!)
                        }
                    }
                    
                }
            }
        }
        return trends
    }
    
    private func parseData (_ results: Any?) -> [Any] {
        var parsedResults: [Any]
        switch requestType {
        case "following":
            parsedResults = parseUsers(results)
        case "trends":
            parsedResults = parseTrends(results)
        default:
//            print(results)
            parsedResults = parseTweets(results)
        }
        return parsedResults
    }
    
    public var newer: Request? {
        if max_id == nil {
            if parameters[Key.sinceID] != nil {
                return self
            }
        } else {
            return modifiedRequest(parametersToChange: [Key.sinceID : max_id!], clearCount: true)
        }
        return nil
    }
    
    private func modifiedRequest(parametersToChange: Dictionary<String,String>, clearCount: Bool = false) -> Request {
        var newParameters = parameters
        for (key, value) in parametersToChange {
            newParameters[key] = value
        }
        if clearCount { newParameters[Key.count] = nil }
        return Request(requestType, newParameters)
    }
    
    public func twitterGetRequest(before handler: @escaping ([Any]) -> Void) {
        performRequest(RequestTypes[requestType]!, "GET", handler: handler)
    }
    
    public func twitterPostRequest(before handler: @escaping ([Any]) -> Void) {
        performRequest(RequestTypes[requestType]!, "POST" ,handler: handler)
    }
    
//    public func getFollowers(before handler: @escaping ([User]) -> Void){
//        print("Entered get followers")
//        performGetRequest(RequestTypes.followers, handler: handler)
//    }
    
    public func performRequest(_ requestType: String,_ requestMethod: String, handler: @escaping ([Any]) -> Void) {
        if let twitterAccountId = Twitter.sharedInstance().sessionStore.session()?.userID {
            let client = TWTRAPIClient(userID: twitterAccountId)
            let requestURL = Constants.twitterURLPrefix + requestType + Constants.JSONExtension
            var clientError : NSError?

            let request = client.urlRequest(withMethod: requestMethod, url: requestURL, parameters: parameters, error: &clientError)
            DispatchQueue.main.async {
                client.sendTwitterRequest(request) { [weak self] (response, responseData, error) -> Void in
                    if let err = error {
                        print("Error: \(err.localizedDescription)")
                    } else {
                        let responseJsonData = try? JSONSerialization.jsonObject(with: responseData!, options: [])
//                        print("network call")
                        //let backToString = String(data: responseData!, encoding: String.Encoding.utf8) as String!
                        print(responseJsonData ?? "Not set")
//                        if self?.requestType == "following" {
//                            handler((self?.parseUsers(responseJsonData))!)
//                        }
//                        else{
//                            handler((self?.parseTweets(responseJsonData))!)
//                        }
                        handler((self?.parseData(responseJsonData))!)
            //                      handler(responseJsonData)
                        //print(backToString ?? "Not converted")
                        //print("User Timeline: \(responseData ?? ))")
                    }
                }
            }
        } else {
        print("Not logged in")
        // Not logged in
        }
    }
    
    private struct Constants {
        static let JSONExtension = ".json"
        static let twitterURLPrefix = "https://api.twitter.com/1.1/"
    }
    
    struct Key {
        static let sinceID = "since_id"
        static let count = "count"
    }
    
    let RequestTypes: Dictionary<String, String> = [
        "home" : "statuses/home_timeline",
        "tweets" : "statuses",
        "search" : "search/tweets",
        "following" : "friends/list",
        "user_timeline" : "statuses/user_timeline",
        "trends" : "trends/place",
        "favorite" : "favorites/create",
        "remove_favorite" : "favorites/destroy",
        "retweet" : "statuses/retweet",
        "undo_retweet" : "statuses/unretweet"
    ]
    
    struct HandlerFunction {
        static let tweets = parseTweets
    }
    
    struct TwitterKey {
//        static let home = "statuses/home_timeline"
        static let tweets = "statuses"
        static let users = "users"
        static let trends = "trends"
        static let name = "name"
//        static let search = "search/tweets"
//        static let following = "friends/list"
    }
}
