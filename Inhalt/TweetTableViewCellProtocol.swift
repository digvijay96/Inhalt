//
//  tweetTableViewCellProtocol.swift
//  Inhalt
//
//  Created by digvijay.s on 11/09/17.
//  Copyright © 2017 digvijay.s. All rights reserved.
//

import Foundation

protocol TweetTableViewCellProtocol {
    func didPressLikeOrRetweetButton(_: [Any]) -> Void
    func editCellDataAfterFavorite(_: Any, changeLikeCountTo _: Int, changeFavouritedTo _: Bool) -> Void
    func editCellDataAfterRetweet(_: Any, changeRetweetCountTo _: Int, changeRetweetedTo _: Bool) -> Void
}
