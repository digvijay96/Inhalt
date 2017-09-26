//
//  TweetWithMediaTableViewCell.swift
//  Inhalt
//
//  Created by digvijay.s on 04/09/17.
//  Copyright © 2017 digvijay.s. All rights reserved.
//

import UIKit

class TweetWithMediaTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var createdLabel: UILabel!
    @IBOutlet weak var tweeterNameLabel: UILabel!
    @IBOutlet weak var tweeterHandleLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
    @IBOutlet weak var tweetImageView: UIImageView!
    
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var retweetButton: UIButton!
    @IBOutlet weak var retweetCountLabel: UILabel!
    
    private var request: Request?
    var tweet: Tweet? {
        didSet{
            updateUI()
        }
    }
    
    var tweetDataDelegate: TweetTableViewCellProtocol?
    
    private func updateUI() {
        tweeterNameLabel?.text = tweet?.user.name
        tweeterHandleLabel?.text = "@" + (tweet?.user.screenName)!
        tweetTextLabel?.text = tweet?.text
        profileImageView?.image = nil
        likeCountLabel.text = String((tweet?.favouriteCount)!)
        retweetCountLabel.text = String((tweet?.retweetCount)!)
        if (tweet?.favorited)! {
            likeButton.setImage(UIImage(named: "Liked"), for: .normal)
        }
        else{
            likeButton.setImage(UIImage(named: "Like"), for: .normal)
        }
        if (tweet?.retweeted)! {
            retweetButton.setImage(UIImage(named: "Retweeted"), for: .normal)
        }
        else {
            retweetButton.setImage(UIImage(named: "Retweet"), for: .normal)
        }
        let id = tweet?.identifier
        let profileImageUrl = tweet?.user.profileImageUrl
        if id == tweet?.identifier {
            profileImageView.sd_setImage(with: profileImageUrl, placeholderImage: nil)
        }
//        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
//            let profileImageUrl = self?.tweet?.user.profileImageUrl
//            if let imageData = try? Data(contentsOf: profileImageUrl!) {
//                DispatchQueue.main.async {
//                    if id == self?.tweet?.identifier {
//                        let profileImage = UIImage(data: imageData)
//                        self?.profileImageView?.image = profileImage
////                            self?.cache?.setObject(profileImage!, forKey: self?.tweet?.user.profileImageUrl as AnyObject)
//                    }
//                }
//            }
//        }
        
        let created = tweet?.created
        let formatter = DateFormatter()
        if Date().timeIntervalSince(created!) > 24*60*60 {
            formatter.dateStyle = .short
        } else {
            formatter.timeStyle = .short
        }
        createdLabel?.text = formatter.string(from: created!)
        tweetImageView.image = nil
        let imageMediaUrl = tweet?.media[0].url
        if id == tweet?.identifier {
            tweetImageView.sd_setImage(with: imageMediaUrl, placeholderImage: UIImage(named: "blue22"))
        }
    }

    
    @IBAction func likeButtonClicked(_ sender: UIButton) {
        if Reachability.isConnectedToNetwork() {
            if (tweet?.favorited)! {
                let parameters: Dictionary<String, String> = ["id": (tweet?.identifier)!]
                request = Request(Request.RequestType.remove_favorite.rawValue, parameters)
                request?.performTweetsPostRequest(handler: {_ in })
                tweetDataDelegate?.editCellDataAfterFavorite(self, changeLikeCountTo: Int(likeCountLabel.text!)!-1, changeFavouritedTo: true)
            }
            else{
                let parameters: Dictionary<String, String> = ["id": (tweet?.identifier)!]
                request = Request(Request.RequestType.favorite.rawValue, parameters)
                request?.performTweetsPostRequest(handler: { _ in })
                tweetDataDelegate?.editCellDataAfterFavorite(self, changeLikeCountTo: Int(likeCountLabel.text!)!+1, changeFavouritedTo: true)
                
            }
        }
    }
    
    
    @IBAction func retweetButtonClicked(_ sender: UIButton) {
        if Reachability.isConnectedToNetwork() {
            if (tweet?.retweeted)! {
                let parameters: Dictionary<String, String> = ["id": (tweet?.identifier)!]
                request = Request(Request.RequestType.undo_retweet.rawValue, parameters)
                request?.performTweetsPostRequest(handler: { _ in })
                tweetDataDelegate?.editCellDataAfterRetweet(self, changeRetweetCountTo: Int(retweetCountLabel.text!)!-1, changeRetweetedTo: true)
                
                //            retweetButton.setImage(UIImage(named: "Retweet"), for: .normal)
                //            retweetCountLabel.text = String(1 + Int(retweetCountLabel.text!)!)
                //            tweet?.retweeted = false
            }
            else {
                let parameters: Dictionary<String, String> = ["id": (tweet?.identifier)!]
                request = Request(Request.RequestType.retweet.rawValue, parameters)
                request?.performTweetsPostRequest(handler: { _ in })
                tweetDataDelegate?.editCellDataAfterRetweet(self, changeRetweetCountTo: Int(retweetCountLabel.text!)!+1, changeRetweetedTo: true)
                //            retweetButton.setImage(UIImage(named: "Retweeted"), for: .normal)
                //            retweetCountLabel.text = String(Int(retweetCountLabel.text!)! - 1)
                //            tweet?.retweeted = true
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profileImageView.layer.borderWidth = 1
        profileImageView.layer.masksToBounds = false
//        profileImageView.layer.borderColor = UIColor.black.cgColor
        profileImageView.layer.cornerRadius = profileImageView.frame.height/2
        profileImageView.clipsToBounds = true
    }


}
