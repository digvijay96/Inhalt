//
//  SearchTrendTableViewCell.swift
//  Inhalt
//
//  Created by digvijay.s on 08/09/17.
//  Copyright © 2017 digvijay.s. All rights reserved.
//

import UIKit

class SearchTrendTableViewCell: UITableViewCell {

    
    @IBOutlet weak var searchTrendLabel: UILabel!
    
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
    
    public var trend: String? {
        didSet{
            updateUI()
        }
    }
    
    private func updateUI() {
        searchTrendLabel.text = trend
    }

}
