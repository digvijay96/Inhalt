//
//  SearchTweetsTableViewCell.swift
//  Inhalt
//
//  Created by digvijay.s on 31/08/17.
//  Copyright © 2017 digvijay.s. All rights reserved.
//

import UIKit

class SearchTweetsTableViewCell: UITableViewCell {

    @IBOutlet weak var tweeterName: UILabel!
    @IBOutlet weak var tweeterHandle: UILabel!
    @IBOutlet weak var tweetText: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var dateCreated: UILabel!
    
    var tweet: Tweet? {
        didSet{
            updateUI()
        }
    }
    
    private func updateUI(){
        profileImage.layer.borderWidth = 1
        profileImage.layer.masksToBounds = false
        profileImage.layer.borderColor = UIColor.black.cgColor
        profileImage.layer.cornerRadius = profileImage.frame.height/2
        profileImage.clipsToBounds = true
        tweeterName?.text = tweet?.user.name
        tweeterHandle?.text = "@" + (tweet?.user.screenName)!
        tweetText?.text = tweet?.text
        profileImage.image = nil
        let id = tweet?.identifier
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            if let profileImageUrl = self?.tweet?.user.profileImageUrl {
                if let imageData = try? Data(contentsOf: profileImageUrl) {
                    DispatchQueue.main.async { [weak self] in
                        if id == self?.tweet?.identifier{
                            self?.profileImage?.image = UIImage(data: imageData)
                        }
                    }
                } else {
                    self?.profileImage?.image = nil
                }
            }
        }
        
        if let created = tweet?.created {
            let formatter = DateFormatter()
            if Date().timeIntervalSince(created) > 24*60*60 {
                formatter.dateStyle = .short
            } else {
                formatter.timeStyle = .short
            }
            dateCreated?.text = formatter.string(from: created)
        } else {
            dateCreated?.text = nil
        }
        
    }
    
    
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        // Initialization code
//    }
//
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }

}
