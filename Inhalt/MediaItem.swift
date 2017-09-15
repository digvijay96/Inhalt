//
//  MediaItem.swift
//  Inhalt
//
//  Created by digvijay.s on 04/09/17.
//  Copyright © 2017 digvijay.s. All rights reserved.
//

import Foundation

public struct MediaItem {
    public var url: URL
    public var aspectRatio: Double?
    
    init?(data: NSDictionary?) {
        guard
            let height = data?.value(forKeyPath: TwitterKey.height) as? Double, height > 0,
            let width = data?.value(forKeyPath: TwitterKey.width) as? Double, width > 0,
            let urlString = data?.value(forKeyPath: TwitterKey.mediaURL) as? String
            else {
                return nil
            }
        let convertedUrl = URL(string: urlString)
        self.url = convertedUrl!
        self.aspectRatio = width/height
    }
    
    init(_ mediaItemUrl: String) {
        let convertedUrl = URL(string: mediaItemUrl)
        self.url = convertedUrl!
        self.aspectRatio = 2.0
    }
    
    struct TwitterKey {
        static let mediaURL = "media_url_https"
        static let width = "sizes.small.w"
        static let height = "sizes.small.h"
    }

}
