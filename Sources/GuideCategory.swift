//
//  GuideCategory.swift
//  YouTubeKit
//
//  Created by Hiroki Kumamoto on 2017/04/07.
//  Copyright © 2017 Hiroki Kumamoto. All rights reserved.
//

import Foundation
import SwiftyJSON

open class GuideCategory: Hashable, Equatable, JSONSerializable {
    open let etag:      String
    open let id:        String
    open let kind:      String
    open let channelId: String!
    open let title:     String!
    open var hashValue: Int { return id.hashValue }
    
    public required init(json: JSON) {
        etag = json["etag"].stringValue
        id   = json["id"].stringValue
        kind = json["kind"].stringValue
        if let snippet = json["snippet"].dictionary {
            channelId = snippet["channelId"]!.stringValue
            title     = snippet["title"]!.stringValue
        } else {
            channelId = nil
            title     = nil
        }
    }
}

public func ==(lhs: GuideCategory, rhs: GuideCategory) -> Bool {
    return lhs.id == rhs.id
}
