//
//  Playlist.swift
//  YouTubeKit
//
//  Created by Hiroki Kumamoto on 2017/04/07.
//  Copyright © 2017 Hiroki Kumamoto. All rights reserved.
//

import Foundation
import SwiftyJSON

open class Playlist: Resource, Hashable, Equatable, JSONSerializable {
    open class var url: String { return "https://www.googleapis.com/youtube/v3/playlists" }
    open class var params: [String:String] { return ["mine": "true"] }
    open var hashValue: Int { return id.hashValue }
    open let etag:        String
    open let id:          String
    open let kind:        String
    open let title:       String!
    open let description: String!
    open let publishedAt: String?
    open let thumbnails:  [String:String]
    open let resourceId:  [String:String]
    
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
    
    public init(id: String, title: String) {
        self.etag        = id
        self.id          = id
        self.kind        = "playlistItem"
        self.title       = title
        self.description = title
        self.publishedAt = nil
        self.thumbnails  = [:]
        self.resourceId  = [:]
    }
    
    open var thumbnailURL: URL? {
        if let url = thumbnails["default"] { return URL(string: url) }
        else if let url = thumbnails["medium"]  { return URL(string: url) }
        else if let url = thumbnails["high"]    { return URL(string: url) }
        else                                    { return nil }
    }
}

public func ==(lhs: Playlist, rhs: Playlist) -> Bool {
    return lhs.id == rhs.id
}
