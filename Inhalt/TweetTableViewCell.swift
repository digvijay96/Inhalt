//
//  TweetTableViewCell.swift
//  Inhalt
//
//  Created by digvijay.s on 06/09/17.
//  Copyright © 2017 digvijay.s. All rights reserved.
//

import UIKit

class TweetTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var createdLabel: UILabel!
    @IBOutlet weak var tweeterNameLabel: UILabel!
    @IBOutlet weak var tweeterHandleLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var retweetCountLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var retweetButton: UIButton!
    
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
//        print(tweet?.text ?? "")
//        print(tweet?.favorited ?? "")
        if (tweet?.favorited)! {
            likeButton.setImage(UIImage(named: "Liked"), for: .normal)
        }
        else{
            likeButton.setImage(UIImage(named: "Like"), for: .normal)
        }
        if (tweet?.retweeted)! {
            retweetButton.setImage(UIImage(named: "Retweeted"), for: .normal)
        }
        else{
            retweetButton.setImage(UIImage(named: "Retweet"), for: .normal)
        }
        let id = tweet?.identifier
        DispatchQueue.global(qos: .userInitiated).async {
            let profileImageUrl = self.tweet?.user.profileImageUrl
            if let imageData = try? Data(contentsOf: profileImageUrl!) {
                DispatchQueue.main.async {
                    if id == self.tweet?.identifier {
                        self.profileImageView?.image = UIImage(data: imageData)
                    }
                }
            }
        }
        
        let created = tweet?.created
        let formatter = DateFormatter()
        if Date().timeIntervalSince(created!) > 24*60*60 {
            formatter.dateStyle = .short
        } else {
            formatter.timeStyle = .short
        }
        createdLabel?.text = formatter.string(from: created!)
    }
    

    
    @IBAction func likeButtonClicked(_ sender: UIButton) {
        if (tweet?.favorited)! {
            let parameters: Dictionary<String, String> = ["id": (tweet?.identifier)!]
            request = Request("remove_favorite", parameters)
            request?.twitterPostRequest(before: (tweetDataDelegate?.didPressLikeOrRetweetButton)!)
            tweetDataDelegate?.editCellDataAfterFavorite(self, changeLikeCountTo: Int(likeCountLabel.text!)!-1, changeFavouritedTo: false)
//            DispatchQueue.main.async { [weak self] in
//                self?.likeButton.setImage(UIImage(named: "Like"), for: .normal)
//                let likeCount = Int((self?.likeCountLabel.text!)!)
//                self?.likeCountLabel.text = String(likeCount! - 1)
//            }
            
//            tweet?.favorited = false
        }
        else{
            let parameters: Dictionary<String, String> = ["id": (tweet?.identifier)!]
            request = Request("favorite", parameters)
            request?.twitterPostRequest(before: (tweetDataDelegate?.didPressLikeOrRetweetButton)!)
            tweetDataDelegate?.editCellDataAfterFavorite(self, changeLikeCountTo: Int(likeCountLabel.text!)!+1, changeFavouritedTo: true)
//            tweetDataDelegate?.editCellData(self)
//            DispatchQueue.main.async { [weak self] in
//                self?.likeButton.setImage(UIImage(named: "Liked"), for: .normal)
//                let likeCount = Int((self?.likeCountLabel.text!)!)
//                self?.likeCountLabel.text = String(likeCount! + 1)
//            }
//            tweet?.favorited = true
        }
    }
    
    @IBAction func retweetButtonClicked(_ sender: UIButton) {
//        if tweet?.retweeted {
//            let parameters: Dictionary<String, String> = ["id": (tweet?.identifier)!]
//            request = Request("remove_favorite", parameters)
//            request?.twitterPostRequest(before: (tweetDataDelegate?.didPressLikeButton)!)
//        }
        if (tweet?.retweeted)! {
            let parameters: Dictionary<String, String> = ["id": (tweet?.identifier)!]
            request = Request("undo_retweet", parameters)
            request?.twitterPostRequest(before: (tweetDataDelegate?.didPressLikeOrRetweetButton)!)
            tweetDataDelegate?.editCellDataAfterRetweet(self, changeRetweetCountTo: Int(retweetCountLabel.text!)!-1, changeRetweetedTo: false)
//            retweetButton.setImage(UIImage(named: "Retweet"), for: .normal)
//            retweetCountLabel.text = String(1 + Int(retweetCountLabel.text!)!)
//            tweet?.retweeted = false
        }
        else {
            let parameters: Dictionary<String, String> = ["id": (tweet?.identifier)!]
            request = Request("retweet", parameters)
            request?.twitterPostRequest(before: (tweetDataDelegate?.didPressLikeOrRetweetButton)!)
            tweetDataDelegate?.editCellDataAfterRetweet(self, changeRetweetCountTo: Int(retweetCountLabel.text!)!+1, changeRetweetedTo: true)
//            retweetButton.setImage(UIImage(named: "Retweeted"), for: .normal)
//            retweetCountLabel.text = String(Int(retweetCountLabel.text!)! - 1)
//            tweet?.retweeted = true
        }
        
//        retweetButton.setImage(UIImage(named: "Retweet-48"), for: .normal)
//        retweetCountLabel.text = String(1 + Int(retweetCountLabel.text!)!)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        profileImageView.layer.borderWidth = 1
        profileImageView.layer.masksToBounds = false
        profileImageView.layer.borderColor = UIColor.black.cgColor
        profileImageView.layer.cornerRadius = profileImageView.frame.height/2
        profileImageView.clipsToBounds = true
//        likeButton.setImage(UIImage(named: "Heart-50"), for: .normal)
//        retweetButton.setImage(UIImage(named: "Retweet-50"), for: .normal)
//        likeCountLabel.text = "10"
//        retweetCountLabel.text = "10"
    }
//
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }
    
}
