//
//  ChannelResource.swift
//  YouTubeKit
//
//  Created by Hiroki Kumamoto on 2017/04/07.
//  Copyright © 2017 Hiroki Kumamoto. All rights reserved.
//

import Foundation
import SwiftyJSON

open class ChannelResource: JSONSerializable {
    public let etag:        String
    public let id:          String
    public let kind:        String
    public let title:       String!
    public let description: String!
    public let publishedAt: String?
    public let thumbnails: [String:String]
    public let resourceId: [String:String]
    public static func resourceId(_ snippet: [String: JSON]) -> [String:String] {
        var resId: [String:String] = [:]
        if let r = snippet["resourceId"]?.dictionary {
            for key in r.keys {
                resId[key] = r[key]!.stringValue
            }
        }
        return resId
    }
    public static func thumbnails(_ snippet: [String: JSON]) -> [String:String] {
        var thumbs: [String:String] = [:]
        if let d = snippet["thumbnails"]?.dictionary {
            for k in d.keys {
                thumbs[k] = d[k]!["url"].stringValue
            }
        }
        return thumbs
    }
    public required init(json: JSON) {
        let snippet = json["snippet"].dictionaryValue
        etag        = json["etag"].stringValue
        id          = json["id"].stringValue
        kind        = json["kind"].stringValue
        title       = snippet["title"]!.stringValue
        description = snippet["description"]!.stringValue
        publishedAt = snippet["publishedAt"]?.string
        thumbnails  = ChannelResource.thumbnails(snippet)
        resourceId  = ChannelResource.resourceId(snippet)
    }
    public init(etag: String,
                id: String,
                kind: String,
                title: String,
                description: String,
                publishedAt: String?,
                thumbnails: [String:String],
                resourceId: [String:String]) {
        self.etag        = etag
        self.id          = id
        self.kind        = kind
        self.title       = title
        self.description = description
        self.publishedAt = publishedAt
        self.thumbnails  = thumbnails
        self.resourceId  = resourceId
    }
    open var thumbnailURL: URL? {
        if let url = thumbnails["default"] { return URL(string: url) }
        else if let url = thumbnails["medium"]  { return URL(string: url) }
        else if let url = thumbnails["high"]    { return URL(string: url) }
        else                                    { return nil }
    }
}

