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
    static var requestCompleted = true
    
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
//        print(following)
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
    
    public func performTrendsRequest(handler: @escaping ([String]) -> Void) {
        if let twitterAccountId = Twitter.sharedInstance().sessionStore.session()?.userID {
            let client = TWTRAPIClient(userID: twitterAccountId)
            let requestURL = Constants.twitterURLPrefix + requestType + Constants.JSONExtension
            print(requestURL)
            var clientError : NSError?

            let request = client.urlRequest(withMethod: "GET", url: requestURL, parameters: parameters, error: &clientError)
            DispatchQueue.main.async {
                client.sendTwitterRequest(request) { [weak self] (response, responseData, error) -> Void in
                    if let err = error {
                        print("Error: \(err.localizedDescription)")
                        handler([])
                    } else {
                        
                        let responseJsonData = try? JSONSerialization.jsonObject(with: responseData!, options: [])
                        if Request.requestCompleted {
                            Request.requestCompleted = false
                            if let strongSelf = self {
                                handler((strongSelf.parseTrends(responseJsonData)))
                            }
                        }
                    }
                    Request.requestCompleted = true
                }
            }
        } else {
        print("Not logged in")
        }
    }
    
    public func performTweetsPostRequest(handler: @escaping ([Tweet]) -> Void) {
        if let twitterAccountId = Twitter.sharedInstance().sessionStore.session()?.userID {
            let client = TWTRAPIClient(userID: twitterAccountId)
            let requestURL = Constants.twitterURLPrefix + requestType + Constants.JSONExtension
            print(requestURL)
            var clientError : NSError?
            
            let request = client.urlRequest(withMethod: "POST", url: requestURL, parameters: parameters, error: &clientError)
            DispatchQueue.main.async {
                client.sendTwitterRequest(request) { [weak self] (response, responseData, error) -> Void in
                    if let err = error {
                        print("Error: \(err.localizedDescription)")
                        handler([])
                    } else {
                        
                        let responseJsonData = try? JSONSerialization.jsonObject(with: responseData!, options: [])
                        if Request.requestCompleted {
                            Request.requestCompleted = false
                            if let strongSelf = self {
                                handler((strongSelf.parseTweets(responseJsonData)))
                            }
                        }
                    }
                    Request.requestCompleted = true
                }
            }
        } else {
            print("Not logged in")
        }
        
    }
    
    public func performTweetsGetRequest(handler: @escaping ([Tweet]) -> Void) {
        if let twitterAccountId = Twitter.sharedInstance().sessionStore.session()?.userID {
            let client = TWTRAPIClient(userID: twitterAccountId)
            let requestURL = Constants.twitterURLPrefix + requestType + Constants.JSONExtension
            print(requestURL)
            var clientError : NSError?
            
            let request = client.urlRequest(withMethod: "GET", url: requestURL, parameters: parameters, error: &clientError)
            DispatchQueue.main.async {
                client.sendTwitterRequest(request) { [weak self] (response, responseData, error) -> Void in
                    //                    if let strongSelf = self {
                    //
                    //                    }
                    if let err = error {
                        print("Error: \(err.localizedDescription)")
                    } else {
                        
                        let responseJsonData = try? JSONSerialization.jsonObject(with: responseData!, options: [])
                        if Request.requestCompleted {
                            Request.requestCompleted = false
                            if let strongSelf = self {
                                handler((strongSelf.parseTweets(responseJsonData)))
                            }
                        }
                    }
                    Request.requestCompleted = true
                }
            }
        } else {
            print("Not logged in")
        }

    }
    
    public func performUsersRequest(handler: @escaping ([User]) -> Void) {
        if let twitterAccountId = Twitter.sharedInstance().sessionStore.session()?.userID {
            let client = TWTRAPIClient(userID: twitterAccountId)
            let requestURL = Constants.twitterURLPrefix + requestType + Constants.JSONExtension
            var clientError : NSError?
            
            let request = client.urlRequest(withMethod: "GET", url: requestURL, parameters: parameters, error: &clientError)
            DispatchQueue.main.async {
                client.sendTwitterRequest(request) { [weak self] (response, responseData, error) -> Void in
                    if let err = error {
                        print("Error: \(err.localizedDescription)")
                    } else {
                        
                        let responseJsonData = try? JSONSerialization.jsonObject(with: responseData!, options: [])
                        if Request.requestCompleted {
                            Request.requestCompleted = false
                            if let strongSelf = self {
                                handler((strongSelf.parseUsers(responseJsonData)))
                            }
                        }
                    }
                    Request.requestCompleted = true
                }
            }
        } else {
            print("Not logged in")
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
    
    enum RequestType: String {
        case home = "statuses/home_timeline"
        case tweets = "statuses"
        case search = "search/tweets"
        case following = "friends/list"
        case user_timeline = "statuses/user_timeline"
        case trends = "trends/place"
        case favorite = "favorites/create"
        case remove_favorite = "favorites/destroy"
        case retweet = "statuses/retweet"
        case undo_retweet = "statuses/unretweet"
        case new_status = "statuses/update"
        case user_details = "users/show"
        case verify_credentials = "account/verify_credentials"
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
