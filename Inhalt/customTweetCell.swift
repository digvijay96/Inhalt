//
//  customTweetCellView.swift
//  Inhalt
//
//  Created by digvijay.s on 05/09/17.
//  Copyright © 2017 digvijay.s. All rights reserved.
//

import UIKit

class customTweetCell: UITableViewCell {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        commonInit()
//    }
////    
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//    }
//    
//    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//    }

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var createdLabel: UILabel!
    @IBOutlet weak var tweeterNameLabel: UILabel!
    @IBOutlet weak var tweeterHandleLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
    
    
    
//    private func commonInit() {
//        Bundle.main.loadNibNamed("TweetTableViewCell", owner: self, options: nil)
//        addSubview(tweetCellView)
//        tweetCellView.frame = self.bounds
//        tweetCellView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
//    }
    
}
